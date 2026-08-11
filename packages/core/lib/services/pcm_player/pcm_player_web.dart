// ignore_for_file: avoid_web_libraries_in_flutter, uri_does_not_exist, undefined_class, undefined_function, undefined_method, invalid_assignment, undefined_prefixed_name
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'pcm_player_interface.dart';

PcmPlayer getPcmPlayer() => PcmPlayerWeb();

class PcmPlayerWeb implements PcmPlayer {
  dynamic _audioCtx;
  num _nextStartTime = 0;
  int _sampleRate = 24000;

  @override
  Future<void> initialize({int sampleRate = 24000}) async {
    _sampleRate = sampleRate;
    _initCtx();
  }
  
  void _initCtx() {
    final window = html.window;
    final audioContext = js_util.getProperty(window, 'AudioContext') ?? 
                         js_util.getProperty(window, 'webkitAudioContext');
    if (audioContext != null) {
      _audioCtx = js_util.callConstructor(audioContext, []);
    }
  }

  @override
  Future<void> start() async {
    if (_audioCtx != null) {
      final state = js_util.getProperty(_audioCtx, 'state');
      if (state == 'suspended') {
        js_util.callMethod(_audioCtx, 'resume', []);
      }
    }
  }

  @override
  Future<void> stop() async {
    _nextStartTime = 0;
    if (_audioCtx != null) {
      try {
        js_util.callMethod(_audioCtx, 'close', []);
      } catch (_) {}
    }
    _initCtx();
  }

  @override
  void writeChunk(Uint8List pcm) {
    if (_audioCtx == null) return;
    
    final int16Data = pcm.buffer.asInt16List(pcm.offsetInBytes, pcm.lengthInBytes ~/ 2);
    final numSamples = int16Data.length;
    
    final audioBuffer = js_util.callMethod(_audioCtx, 'createBuffer', [1, numSamples, _sampleRate]);
    final channelData = js_util.callMethod(audioBuffer, 'getChannelData', [0]) as Float32List;
    
    for (int i = 0; i < numSamples; i++) {
      channelData[i] = int16Data[i] / 32768.0;
    }
    
    final source = js_util.callMethod(_audioCtx, 'createBufferSource', []);
    js_util.setProperty(source, 'buffer', audioBuffer);
    js_util.callMethod(source, 'connect', [js_util.getProperty(_audioCtx, 'destination')]);
    
    final currentTime = js_util.getProperty(_audioCtx, 'currentTime') as num;
    if (_nextStartTime < currentTime) {
      _nextStartTime = currentTime;
    }
    
    js_util.callMethod(source, 'start', [_nextStartTime]);
    final duration = js_util.getProperty(audioBuffer, 'duration') as num;
    _nextStartTime += duration;
  }

  @override
  void dispose() {
    stop();
  }
}
