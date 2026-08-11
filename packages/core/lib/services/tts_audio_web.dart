// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

String? _lastBlobUrl;

/// Web: MP3 baytlarini Blob URL orqali ijro etadi (data URI ishonchsiz).
Future<void> playMp3Bytes(AudioPlayer player, Uint8List bytes) async {
  if (_lastBlobUrl != null) {
    html.Url.revokeObjectUrl(_lastBlobUrl!);
    _lastBlobUrl = null;
  }

  final blob = html.Blob([bytes], 'audio/mpeg');
  final url = html.Url.createObjectUrlFromBlob(blob);
  _lastBlobUrl = url;

  await player.play(UrlSource(url));
}
