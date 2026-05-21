import 'dart:async';
import 'dart:math';

import 'package:speech_to_text/speech_to_text.dart';

/// Speech-to-text for Sprechen AI (German).
class STTService {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;
  String _lastWords = '';
  final _random = Random();

  Future<bool> _ensureReady() async {
    if (_available) return true;
    _available = await _speech.initialize();
    return _available;
  }

  Future<bool> startRecording() async {
    if (!await _ensureReady()) return false;
    _lastWords = '';

    await _speech.listen(
      onResult: (result) => _lastWords = result.recognizedWords,
      listenOptions: SpeechListenOptions(
        localeId: 'de_DE',
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      ),
    );
    return _speech.isListening;
  }

  Future<String> stopAndTranscribe() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    return _lastWords.trim();
  }

  /// Fake amplitude for mic ring animation (speech_to_text has no levels).
  Stream<Amplitude> onAmplitudeChanged(Duration interval) async* {
    while (_speech.isListening) {
      await Future.delayed(interval);
      final db = -20 - _random.nextDouble() * 25;
      yield Amplitude(current: db, max: db);
    }
  }

  void dispose() {
    _speech.stop();
  }
}

class Amplitude {
  final double current;
  final double max;

  const Amplitude({required this.current, required this.max});
}
