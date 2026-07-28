import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

import '../utils/web_blob_url.dart';

/// Text-to-speech for German AI replies.
/// Avval Amazon Polly ishlatiladi. U ishlamasa flutter_tts zaxiraga o'tadi.
class TTSService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  bool _flutterTtsReady = false;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  String? _activeBlobUrl;

  bool isPlaying = false;
  String currentText = '';

  VoidCallback? onPlaybackStateChanged;

  void _notifyState() => onPlaybackStateChanged?.call();

  TTSService() {
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        _revokeActiveBlobUrl();
        isPlaying = false;
        currentText = '';
        _notifyState();
      }
    });
  }

  void _revokeActiveBlobUrl() {
    if (_activeBlobUrl != null) {
      revokeBlobUrl(_activeBlobUrl!);
      _activeBlobUrl = null;
    }
  }

  Future<void> _ensureFlutterTtsReady() async {
    if (_flutterTtsReady) return;
    // Note: TTS language is set dynamically per voiceId in _playWithFlutterTts
    await _flutterTts.setLanguage('de-DE'); // Default
    await _flutterTts.setVolume(1.0);
    _flutterTts.setCompletionHandler(() {
      isPlaying = false;
      currentText = '';
      _notifyState();
    });
    _flutterTts.setCancelHandler(() {
      isPlaying = false;
      currentText = '';
      _notifyState();
    });
    _flutterTts.setErrorHandler((_) {
      isPlaying = false;
      currentText = '';
      _notifyState();
    });
    _flutterTtsReady = true;
  }

  Future<void> play({
    required String text,
    required String voiceId,
    required double rateValue,
  }) async {
    await stop();
    currentText = text;
    isPlaying = true;
    _notifyState();

    // 1. Amazon Polly'ni sinab ko'r
    try {
      await _playWithPolly(text: text, voiceId: voiceId, rateValue: rateValue);
      return;
    } catch (e) {
      debugPrint('[TTS] Amazon Polly failed: $e');
      debugPrint('[TTS] Falling back to FlutterTTS...');
    }

    // 2. Polly ishlamasa flutter_tts ga o'tish
    try {
      await _playWithFlutterTts(
          text: text, voiceId: voiceId, rateValue: rateValue);
    } catch (e) {
      debugPrint('[TTS] FlutterTTS also failed: $e');
      isPlaying = false;
      _notifyState();
      // Ikkala engine ham ishlamadi — chaqiruvchi xatoni ko'rsata olishi uchun
      rethrow;
    }
  }

  Future<void> _playWithPolly({
    required String text,
    required String voiceId,
    required double rateValue,
  }) async {
    final proxyUrl =
        (dotenv.env['CF_WORKER_URL'] ?? '').trim().replaceAll(RegExp(r'/+$'), '');
    final region = dotenv.env['AWS_REGION']?.trim() ?? 'eu-central-1';

    if (proxyUrl.isEmpty) {
      throw Exception('CF_WORKER_URL not set');
    }

    final profile = _voiceProfile(voiceId);

    final ssmlRate = '${((profile.pollyRate * rateValue) * 100).round()}%';
    final ssmlText =
        '<speak><prosody rate="$ssmlRate">${_escapeSsml(text)}</prosody></speak>';

    final isNeural =
        profile.pollyVoiceId == 'Vicki' || profile.pollyVoiceId == 'Daniel';

    final appToken = dotenv.env['APP_TOKEN']?.trim() ?? '';
    final response = await http
        .post(
          Uri.parse(proxyUrl),
          headers: {
            'Content-Type': 'application/json',
            'X-Proxy-Target': 'polly',
            if (appToken.isNotEmpty) 'X-App-Token': appToken,
          },
          body: jsonEncode({
            'region': region,
            'text': ssmlText,
            'voiceId': profile.pollyVoiceId,
            'engine': isNeural ? 'neural' : 'standard',
            'outputFormat': 'mp3',
          }),
        )
        .timeout(const Duration(seconds: 20));

    final contentType = response.headers['content-type'] ?? '';
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Polly proxy error (${response.statusCode}): ${response.body}');
    }
    if (contentType.contains('application/json')) {
      throw Exception('Polly proxy error: ${response.body}');
    }

    final bytes = response.bodyBytes;
    if (bytes.isEmpty) {
      throw Exception('Polly proxy bo\'sh audio qaytardi');
    }

    _revokeActiveBlobUrl();
    if (kIsWeb) {
      final blobUrl = createBlobUrlFromBytes(bytes);
      if (blobUrl != null) {
        _activeBlobUrl = blobUrl;
        await _audioPlayer.play(UrlSource(blobUrl));
      } else {
        final b64 = base64Encode(bytes);
        await _audioPlayer.play(UrlSource('data:audio/mpeg;base64,$b64'));
      }
    } else {
      await _audioPlayer.play(BytesSource(bytes, mimeType: 'audio/mpeg'));
    }
  }

  Future<void> _playWithFlutterTts({
    required String text,
    required String voiceId,
    required double rateValue,
  }) async {
    await _ensureFlutterTtsReady();
    final profile = _voiceProfile(voiceId);
    await _flutterTts.setSpeechRate(profile.flutterRate * rateValue);
    await _flutterTts.setPitch(profile.pitch);

    try {
      final voices = await _flutterTts.getVoices as List?;
      if (voices != null && voices.isNotEmpty) {
        final deVoices = voices.cast<Map>().where(
          (v) => v['locale']?.toString().toLowerCase().startsWith('de') ?? false,
        ).toList();

        if (deVoices.isNotEmpty) {
          final genderPool = deVoices
              .where((v) =>
                  profile.female ? _isFemaleVoice(v) : _isMaleVoice(v))
              .toList();
          final pool = genderPool.isNotEmpty ? genderPool : deVoices;
          final voiceIndex = profile.voiceSlot % pool.length;
          final selectedVoice = pool[voiceIndex];

          if (selectedVoice['name'] != null) {
            await _flutterTts.setVoice({
              'name': selectedVoice['name'].toString(),
              'locale': selectedVoice['locale']?.toString() ?? 'de-DE',
            });
          }
        }
      }
    } catch (e) {
      debugPrint('[TTS] Voice selection failed: $e');
    }

    await _flutterTts.speak(text);
  }

  bool _isFemaleVoice(Map voice) {
    final name = (voice['name']?.toString() ?? '').toLowerCase();
    final gender = (voice['gender']?.toString() ?? '').toLowerCase();
    if (gender == 'female' || gender.contains('female')) return true;
    if (gender == 'male' || gender.contains('male')) return false;
    const hints = [
      'anna', 'petra', 'vicki', 'marlene', 'helena', 'hedda',
      'female', 'woman', 'katja', 'elke',
    ];
    return hints.any((h) => name.contains(h));
  }

  bool _isMaleVoice(Map voice) {
    final name = (voice['name']?.toString() ?? '').toLowerCase();
    final gender = (voice['gender']?.toString() ?? '').toLowerCase();
    if (gender == 'male' || gender.contains('male')) return true;
    if (gender == 'female' || gender.contains('female')) return false;
    const hints = [
      'hans', 'stefan', 'daniel', 'male', 'man', 'thomas',
      'michael', 'conrad', 'killian', 'becker', 'muller',
    ];
    return hints.any((h) => name.contains(h));
  }

  _VoiceProfile _voiceProfile(String voiceId) {
    switch (voiceId) {
      case 'de-DE-ElkeNeural':
        return const _VoiceProfile(
          pollyVoiceId: 'Vicki',
          pollyRate: 0.85,
          flutterRate: 0.52,
          pitch: 1.12,
          female: true,
          voiceSlot: 0,
        );
      case 'de-DE-KatjaNeural':
        return const _VoiceProfile(
          pollyVoiceId: 'Marlene',
          pollyRate: 0.85,
          flutterRate: 0.58,
          pitch: 1.05,
          female: true,
          voiceSlot: 1,
        );
      case 'de-DE-ConradNeural':
        return const _VoiceProfile(
          pollyVoiceId: 'Daniel',
          pollyRate: 0.85,
          flutterRate: 0.55,
          pitch: 0.88,
          female: false,
          voiceSlot: 0,
        );
      case 'de-DE-KillianNeural':
        return const _VoiceProfile(
          pollyVoiceId: 'Hans',
          pollyRate: 0.85,
          flutterRate: 0.60,
          pitch: 0.80,
          female: false,
          voiceSlot: 1,
        );
      default:
        return const _VoiceProfile(
          pollyVoiceId: 'Vicki',
          pollyRate: 0.85,
          flutterRate: 0.55,
          pitch: 1.0,
          female: true,
          voiceSlot: 0,
        );
    }
  }

  String _escapeSsml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }

  Future<void> stop() async {
    if (isPlaying) {
      await _audioPlayer.stop();
      await _flutterTts.stop();
    }
    _revokeActiveBlobUrl();
    isPlaying = false;
    currentText = '';
    _notifyState();
  }

  void dispose() {
    _playerStateSubscription?.cancel();
    _revokeActiveBlobUrl();
    _audioPlayer.dispose();
    _flutterTts.stop();
  }
}

class _VoiceProfile {
  final String pollyVoiceId;
  final double pollyRate;
  final double flutterRate;
  final double pitch;
  final bool female;
  final int voiceSlot;

  const _VoiceProfile({
    required this.pollyVoiceId,
    required this.pollyRate,
    required this.flutterRate,
    required this.pitch,
    required this.female,
    required this.voiceSlot,
  });
}
