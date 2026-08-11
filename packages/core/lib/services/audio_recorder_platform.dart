// Platformaga qarab audio yozish yordamchilari uchun conditional import.
// web_blob_url.dart namunasiga ko'ra: native uchun stub, web uchun web fayl.
export 'audio_recorder_platform_stub.dart'
    if (dart.library.html) 'audio_recorder_platform_web.dart';
