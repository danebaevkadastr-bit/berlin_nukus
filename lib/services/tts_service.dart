import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

/// Text-to-speech for German AI replies.
/// Avval Amazon Polly ishlatiladi. U ishlamasa flutter_tts zaxiraga o'tadi.
class TTSService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  bool _flutterTtsReady = false;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  bool isPlaying = false;
  String currentText = '';

  VoidCallback? onPlaybackStateChanged;

  void _notifyState() => onPlaybackStateChanged?.call();

  TTSService() {
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        isPlaying = false;
        currentText = '';
        _notifyState();
      }
    });
  }

  Future<void> _ensureFlutterTtsReady() async {
    if (_flutterTtsReady) return;
    await _flutterTts.setLanguage('de-DE');
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
      return; // Polly ishlasa tugaymiz
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

    // Tezlikni SSML orqali boshqarish
    final ssmlRate = '${((profile.pollyRate * rateValue) * 100).round()}%';
    final ssmlText =
        '<speak><prosody rate="$ssmlRate">${_escapeSsml(text)}</prosody></speak>';

    // Faqat Vicki va Daniel Neural engine'da ishlaydi, qolganlari standard
    final isNeural =
        profile.pollyVoiceId == 'Vicki' || profile.pollyVoiceId == 'Daniel';

    // Maxfiy AWS kalitlari ilovada saqlanmaydi — presigned URL'ni proksi
    // (Cloudflare Worker) imzolab beradi.
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
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Polly proxy error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final signedUrl = (data['url'] ?? '').toString();
    if (signedUrl.isEmpty) {
      throw Exception('Polly proxy javobida url yo\'q');
    }

    await _audioPlayer.play(UrlSource(signedUrl));
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

    // Mos nemis ovozini qurilmadan qidirish
    try {
      final voices = await _flutterTts.getVoices as List?;
      if (voices != null && voices.isNotEmpty) {
        final gender = profile.female ? 'female' : 'male';
        final match = voices.cast<Map>().firstWhere(
              (v) =>
                  (v['locale']?.toString().startsWith('de') ?? false) &&
                  (v['gender']?.toString().toLowerCase() == gender ||
                      v['name']
                              ?.toString()
                              .toLowerCase()
                              .contains(gender) ==
                          true),
              orElse: () => voices.cast<Map>().firstWhere(
                    (v) => v['locale']?.toString().startsWith('de') ?? false,
                    orElse: () => <String, dynamic>{},
                  ),
            );
        if (match.isNotEmpty && match['name'] != null) {
          await _flutterTts.setVoice({
            'name': match['name'].toString(),
            'locale': match['locale']?.toString() ?? 'de-DE',
          });
        }
      }
    } catch (_) {}

    await _flutterTts.speak(text);
  }

  _VoiceProfile _voiceProfile(String voiceId) {
    // Amazon Polly German Neural voices: Vicki, Marlene, Daniel, Hans
    switch (voiceId) {
      case 'de-DE-ElkeNeural':
        // Frau Schneider — Vicki (Ayol)
        return const _VoiceProfile(
            pollyVoiceId: 'Vicki', pollyRate: 0.85, flutterRate: 0.55, pitch: 1.0, female: true);
      case 'de-DE-KatjaNeural':
        // Frau Fischer — Marlene (Ayol, standard)
        return const _VoiceProfile(
            pollyVoiceId: 'Marlene', pollyRate: 0.85, flutterRate: 0.55, pitch: 1.0, female: true);
      case 'de-DE-ConradNeural':
        // Herr Müller — Daniel (Erkak)
        return const _VoiceProfile(
            pollyVoiceId: 'Daniel', pollyRate: 0.85, flutterRate: 0.55, pitch: 1.0, female: false);
      case 'de-DE-KillianNeural':
        // Herr Becker — Hans (Erkak, standard)
        return const _VoiceProfile(
            pollyVoiceId: 'Hans', pollyRate: 0.85, flutterRate: 0.55, pitch: 1.0, female: false);
      default:
        return const _VoiceProfile(
            pollyVoiceId: 'Vicki', pollyRate: 0.85, flutterRate: 0.55, pitch: 1.0, female: true);
    }
  }

  /// SSML uchun maxsus belgilarni tozalash
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
    isPlaying = false;
    currentText = '';
    _notifyState();
  }

  void dispose() {
    _playerStateSubscription?.cancel();
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

  const _VoiceProfile({
    required this.pollyVoiceId,
    required this.pollyRate,
    required this.flutterRate,
    required this.pitch,
    required this.female,
  });
}
