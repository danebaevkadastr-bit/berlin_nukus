import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-speech for German AI replies.
class TTSService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool isPlaying = false;
  String currentText = '';

  /// O'qish tugaganda yoki bekor qilinganda UI yangilanishi uchun.
  VoidCallback? onPlaybackStateChanged;

  void _notifyState() => onPlaybackStateChanged?.call();

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setLanguage('de-DE');
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      isPlaying = false;
      currentText = '';
      _notifyState();
    });
    _tts.setCancelHandler(() {
      isPlaying = false;
      currentText = '';
      _notifyState();
    });
    _tts.setErrorHandler((_) {
      isPlaying = false;
      currentText = '';
      _notifyState();
    });
    _ready = true;
  }

  Future<void> play({
    required String text,
    required String voiceId,
    required double rateValue,
  }) async {
    await _ensureReady();
    await stop();
    currentText = text;
    isPlaying = true;
    _notifyState();

    // Har bir mentor uchun pitch va rate farqli
    final profile = _voiceProfile(voiceId);
    await _tts.setSpeechRate(profile.rate * rateValue);
    await _tts.setPitch(profile.pitch);

    // Qurilmada mavjud ovozlardan mos ovozni topishga urinish
    try {
      final voices = await _tts.getVoices as List?;
      if (voices != null && voices.isNotEmpty) {
        // Jinsi va tilga mos ovoz qidirish
        final gender = profile.female ? 'female' : 'male';
        final match = voices.cast<Map>().firstWhere(
          (v) =>
              (v['locale']?.toString().startsWith('de') ?? false) &&
              (v['gender']?.toString().toLowerCase() == gender ||
               v['name']?.toString().toLowerCase().contains(gender) == true),
          orElse: () => voices.cast<Map>().firstWhere(
            (v) => v['locale']?.toString().startsWith('de') ?? false,
            orElse: () => <String, dynamic>{},
          ),
        );
        if (match.isNotEmpty && match['name'] != null) {
          await _tts.setVoice({
            'name': match['name'].toString(),
            'locale': match['locale']?.toString() ?? 'de-DE',
          });
        }
      }
    } catch (_) {
      // Ovoz topilmasa davom et
    }

    await _tts.speak(text);
  }

  /// Har bir mentor uchun ovoz profili
  _VoiceProfile _voiceProfile(String voiceId) {
    switch (voiceId) {
      case 'de-DE-ElkeNeural':
        return const _VoiceProfile(pitch: 1.1, rate: 0.55, female: true);
      case 'de-DE-KatjaNeural':
        return const _VoiceProfile(pitch: 1.05, rate: 0.6, female: true);
      case 'de-DE-ConradNeural':
        return const _VoiceProfile(pitch: 0.85, rate: 0.55, female: false);
      case 'de-DE-KillianNeural':
        return const _VoiceProfile(pitch: 0.9, rate: 0.58, female: false);
      default:
        return const _VoiceProfile(pitch: 1.0, rate: 0.6, female: true);
    }
  }

  Future<void> stop() async {
    if (isPlaying) {
      await _tts.stop();
    }
    isPlaying = false;
    currentText = '';
    _notifyState();
  }

  void dispose() {
    _tts.stop();
  }
}

class _VoiceProfile {
  final double pitch;
  final double rate;
  final bool female;
  const _VoiceProfile({
    required this.pitch,
    required this.rate,
    required this.female,
  });
}
