import 'dart:typed_data';
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
