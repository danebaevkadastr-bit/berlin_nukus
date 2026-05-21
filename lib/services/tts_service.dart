import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-speech for German AI replies.
class TTSService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool isPlaying = false;
  String currentText = '';

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setLanguage('de-DE');
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      isPlaying = false;
    });
    _tts.setCancelHandler(() {
      isPlaying = false;
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
    await _tts.setSpeechRate(rateValue.clamp(0.4, 1.2));
    await _tts.speak(text);
  }

  Future<void> stop() async {
    if (isPlaying) {
      await _tts.stop();
    }
    isPlaying = false;
    currentText = '';
  }

  void dispose() {
    _tts.stop();
  }
}
