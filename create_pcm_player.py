import os

os.makedirs('lib/services/pcm_player', exist_ok=True)

with open('lib/services/pcm_player/pcm_player_interface.dart', 'w', encoding='utf-8') as f:
    f.write('''import 'dart:typed_data';

abstract class PcmPlayer {
  Future<void> initialize({int sampleRate = 24000});
  Future<void> start();
  Future<void> stop();
  void writeChunk(Uint8List pcm);
  void dispose();
}
''')

with open('lib/services/pcm_player/pcm_player_stub.dart', 'w', encoding='utf-8') as f:
    f.write('''import 'pcm_player_interface.dart';

PcmPlayer getPcmPlayer() => throw UnsupportedError('Cannot create a PcmPlayer without dart:html or sound_stream');
''')

with open('lib/services/pcm_player/pcm_player_mobile.dart', 'w', encoding='utf-8') as f:
    f.write('''import 'dart:typed_data';
import 'package:sound_stream/sound_stream.dart';
import 'pcm_player_interface.dart';

PcmPlayer getPcmPlayer() => PcmPlayerMobile();

class PcmPlayerMobile implements PcmPlayer {
  final PlayerStream _player = PlayerStream();

  @override
  Future<void> initialize({int sampleRate = 24000}) async {
    await _player.initialize(sampleRate: sampleRate);
  }

  @override
  Future<void> start() async {
    await _player.start();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  void writeChunk(Uint8List pcm) {
    _player.writeChunk(pcm);
  }

  @override
  void dispose() {
    _player.dispose();
  }
}
''')

with open('lib/services/pcm_player/pcm_player_web.dart', 'w', encoding='utf-8') as f:
    f.write('''import 'dart:typed_data';
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
''')

with open('lib/services/pcm_player/pcm_player.dart', 'w', encoding='utf-8') as f:
    f.write('''export 'pcm_player_interface.dart';
export 'pcm_player_stub.dart'
    if (dart.library.html) 'pcm_player_web.dart'
    if (dart.library.io) 'pcm_player_mobile.dart';
''')

# Now update gemini_live_service.dart to use it
with open("lib/services/gemini_live_service.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("import 'package:sound_stream/sound_stream.dart';", "import 'pcm_player/pcm_player.dart';")
content = content.replace("final PlayerStream _playerStream = PlayerStream();", "final PcmPlayer _playerStream = getPcmPlayer();")

with open("lib/services/gemini_live_service.dart", "w", encoding="utf-8") as f:
    f.write(content)

print("done")
