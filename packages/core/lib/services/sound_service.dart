import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playCorrect() async {
    await _player.play(AssetSource('sounds/richtig.mp3'));
  }

  static Future<void> playIncorrect() async {
    await _player.play(AssetSource('sounds/flasch.mp3'));
  }

  static Future<void> stop() async {
    await _player.stop();
  }
}
