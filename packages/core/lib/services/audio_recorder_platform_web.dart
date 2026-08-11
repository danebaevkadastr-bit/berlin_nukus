// Web platforma yordamchilari.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

/// Web uchun afzal audio MIME turi (record paketi opus/webm yozadi).
const String platformAudioMimeType = 'audio/webm';

/// Web uchun kengaytma (faqat ichki nom uchun; brauzer blob ishlatadi).
const String platformAudioExtension = 'webm';

/// Yozilgan audio joyidan (web: blob URL) baytlarni o'qiydi.
Future<Uint8List> readAudioBytes(String pathOrUrl) async {
  // Blob URL'dan baytlarni HttpRequest orqali o'qiymiz.
  final request = await html.HttpRequest.request(
    pathOrUrl,
    responseType: 'arraybuffer',
  );
  final buffer = request.response as ByteBuffer;
  return buffer.asUint8List();
}

/// Web'da fayl o'chirish o'rniga blob URL'ni bekor qilamiz.
Future<void> deleteAudioFile(String pathOrUrl) async {
  revokeAudioUrl(pathOrUrl);
}

/// Web'da record paketi yo'lni o'zi boshqaradi — bo'sh string yetarli.
Future<String> newRecordingPath(String name) async => '';

/// Blob URL'ni bekor qiladi (xotirani bo'shatish).
void revokeAudioUrl(String url) {
  try {
    html.Url.revokeObjectUrl(url);
  } catch (_) {}
}
