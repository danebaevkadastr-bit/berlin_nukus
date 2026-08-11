// Native (Android/iOS/desktop) platforma yordamchilari.
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Native uchun afzal audio MIME turi (record paketi AAC/m4a yozadi).
const String platformAudioMimeType = 'audio/mp4';

/// record paketi uchun afzal fayl kengaytmasi.
const String platformAudioExtension = 'm4a';

/// Yozilgan audio joyidan (native: fayl yo'li) baytlarni o'qiydi.
Future<Uint8List> readAudioBytes(String pathOrUrl) async {
  final file = File(pathOrUrl);
  return file.readAsBytes();
}

/// Vaqtinchalik audio faylni o'chiradi (native).
Future<void> deleteAudioFile(String pathOrUrl) async {
  try {
    final file = File(pathOrUrl);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (_) {
    // o'chirib bo'lmasa — e'tiborsiz qoldiramiz (vaqtinchalik fayl)
  }
}

/// Yangi yozish uchun vaqtinchalik fayl yo'lini beradi (native).
/// Androidda `Directory.systemTemp` ba'zan `/tmp` ga yo'naladi va yozib
/// bo'lmaydi — shu sabab path_provider'ning kafolatlangan cache papkasini
/// ishlatamiz.
Future<String> newRecordingPath(String name) async {
  Directory dir;
  try {
    dir = await getTemporaryDirectory();
  } catch (_) {
    dir = Directory.systemTemp;
  }
  // Fayl nomidagi mumkin bo'lmagan belgilarni tozalaymiz.
  final safe = name.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  return '${dir.path}${Platform.pathSeparator}$safe.$platformAudioExtension';
}

/// Native'da blob URL bo'lmaydi.
void revokeAudioUrl(String url) {}
