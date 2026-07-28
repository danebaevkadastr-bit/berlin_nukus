import 'dart:typed_data';

abstract class PcmPlayer {
  Future<void> initialize({int sampleRate = 24000});
  Future<void> start();
  Future<void> stop();
  void writeChunk(Uint8List pcm);
  void dispose();
}
