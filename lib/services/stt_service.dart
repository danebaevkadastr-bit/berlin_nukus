import 'dart:async';
import 'dart:math';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// Speech-to-text for Sprechen AI (German).
class STTService {
  final SpeechToText _speech = SpeechToText();
  final _random = Random();
  bool _available = false;
  String _lastWords = '';

  Future<bool> _checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    debugPrint('STT: Microphone permission status: $status');
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      debugPrint('STT: Permission request result: $result');
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      debugPrint('STT: Permission permanently denied, opening settings');
      await openAppSettings();
      return false;
    }
    
    return false;
  }

  Future<bool> _ensureReady() async {
    if (_available) return true;
    
    // First check microphone permission
    if (!await _checkMicrophonePermission()) {
      debugPrint('STT: Microphone permission not granted');
      return false;
    }
    
    try {
      _available = await _speech.initialize(
        onError: (error) {
          debugPrint('STT Error: ${error.errorMsg}');
        },
        onStatus: (status) {
          debugPrint('STT Status: $status');
        },
      );
      
      if (_available) {
        final locales = await _speech.locales();
        debugPrint('Available locales: ${locales.map((l) => l.localeId).join(", ")}');
      } else {
        debugPrint('STT initialization failed');
      }
    } catch (e) {
      debugPrint('STT initialization error: $e');
      _available = false;
    }
    
    return _available;
  }

  Future<bool> startRecording() async {
    debugPrint('STT: startRecording called');
    
    if (!await _ensureReady()) {
      debugPrint('STT: Not ready/available');
      return false;
    }
    
    _lastWords = '';

    try {
      await _speech.listen(
        onResult: (result) {
          debugPrint('STT Result: ${result.recognizedWords}');
          _lastWords = result.recognizedWords;
        },
        listenOptions: SpeechListenOptions(
          localeId: 'de_DE',
          listenMode: ListenMode.confirmation,
          cancelOnError: false,
          partialResults: true,
          autoPunctuation: true,
        ),
      );
      
      debugPrint('STT: Listening started, isListening=${_speech.isListening}');
      return _speech.isListening;
    } catch (e) {
      debugPrint('STT: Error starting recording: $e');
      return false;
    }
  }

  Future<String> stopAndTranscribe() async {
    debugPrint('STT: stopAndTranscribe called');
    
    if (_speech.isListening) {
      await _speech.stop();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    
    debugPrint('STT: Final transcription: $_lastWords');
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
