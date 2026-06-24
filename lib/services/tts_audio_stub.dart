import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

Future<void> playMp3Bytes(AudioPlayer player, Uint8List bytes) async {
  await player.play(BytesSource(bytes, mimeType: 'audio/mpeg'));
}
