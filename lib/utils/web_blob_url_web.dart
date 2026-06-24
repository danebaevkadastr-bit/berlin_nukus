import 'dart:html' as html;

/// Web: katta MP3 fayllar uchun data URI o'rniga blob URL ishlatiladi.
String? createBlobUrlFromBytes(List<int> bytes) {
  final blob = html.Blob([bytes]);
  return html.Url.createObjectUrlFromBlob(blob);
}

void revokeBlobUrl(String url) {
  html.Url.revokeObjectUrl(url);
}
