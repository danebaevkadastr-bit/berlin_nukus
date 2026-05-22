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
    await _tts.setPitch(0.95); // Tabiiyroq ovoz uchun pitch biroz pastroq
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
    await _tts.setSpeechRate(rateValue.clamp(0.4, 1.2));
    await _tts.speak(text);
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
