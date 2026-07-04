import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'audio_recorder_platform.dart';

/// Mikrofon ruxsati natijasi.
enum MicPermissionResult { granted, denied, permanentlyDenied }

/// Yozish to'xtaganda qaytariladigan natija.
class RecordedAudio {
  final String pathOrBlobUrl;
  final String mimeType;
  final bool reachedMaxLength;

  const RecordedAudio({
    required this.pathOrBlobUrl,
    required this.mimeType,
    required this.reachedMaxLength,
  });
}

/// Audio yozishni boshqaradigan xizmat. Bitta `AudioRecorder` instansi —
/// bir vaqtda faqat bitta yozish (Requirement 3.5). Native AAC/m4a, web
/// opus/webm. 240 soniyalik limit va avtomatik to'xtash.
class AudioRecorderService {
  AudioRecorderService._();
  static final AudioRecorderService instance = AudioRecorderService._();

  /// Maksimal yozish davomiyligi (soniya) — 4 daqiqa.
  static const int maxDurationSeconds = 240;

  final AudioRecorder _recorder = AudioRecorder();

  Timer? _timer;
  int _elapsed = 0;
  bool _isRecording = false;
  bool _reachedMax = false;

  final StreamController<int> _elapsedController =
      StreamController<int>.broadcast();

  /// O'tgan vaqt (soniya) oqimi — UI timerini yangilash uchun.
  Stream<int> get elapsed => _elapsedController.stream;

  /// Hozir yozish ketyaptimi.
  bool get isRecording => _isRecording;

  /// Joriy platforma audio yozishni qo'llab-quvvatlaydimi.
  /// (record paketi Android/iOS/web/desktop'ni qo'llaydi.)
  static bool get isSupportedPlatform => true;

  /// Mikrofon ruxsati bor-yo'qligini tekshiradi.
  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (_) {
      return false;
    }
  }

  /// Mikrofon ruxsatini so'raydi va natijani qaytaradi.
  Future<MicPermissionResult> requestPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted || status.isLimited) {
      return MicPermissionResult.granted;
    }
    if (status.isPermanentlyDenied) {
      return MicPermissionResult.permanentlyDenied;
    }
    return MicPermissionResult.denied;
  }

  /// Qurilma sozlamalarini ochadi (butunlay rad etilganda).
  Future<void> openSettings() => openAppSettings();

  /// Yozishni boshlaydi. Avval boshqa yozish ketayotgan bo'lsa to'xtatadi.
  /// [onAutoStop] — 240s da avtomatik to'xtaganda chaqiriladi.
  Future<void> start({
    required String recordingName,
    required void Function(RecordedAudio) onAutoStop,
  }) async {
    // Bir vaqtda faqat bitta yozish — avval boshqasini to'xtatamiz.
    if (_isRecording) {
      await cancel();
    }

    final path = await newRecordingPath(recordingName);

    const configWeb = RecordConfig(
      encoder: AudioEncoder.opus,
      numChannels: 1,
      sampleRate: 16000,
      bitRate: 32000,
    );
    const configNative = RecordConfig(
      encoder: AudioEncoder.aacLc,
      numChannels: 1,
      sampleRate: 16000,
      bitRate: 32000,
    );
    const config = kIsWeb ? configWeb : configNative;
    await _recorder.start(config, path: path);

    _isRecording = true;
    _reachedMax = false;
    _elapsed = 0;
    _elapsedController.add(0);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      _elapsed++;
      _elapsedController.add(_elapsed);
      if (_elapsed >= maxDurationSeconds) {
        _reachedMax = true;
        final result = await stop();
        if (result != null) onAutoStop(result);
      }
    });
  }

  /// Yozishni to'xtatadi va natijani qaytaradi. Yozish bo'lmasa null.
  Future<RecordedAudio?> stop() async {
    if (!_isRecording) return null;
    _timer?.cancel();
    _timer = null;
    _isRecording = false;

    final path = await _recorder.stop();
    if (path == null || path.isEmpty) return null;

    return RecordedAudio(
      pathOrBlobUrl: path,
      mimeType: platformAudioMimeType,
      reachedMaxLength: _reachedMax,
    );
  }

  /// Yozishni bekor qiladi (natija saqlanmaydi).
  Future<void> cancel() async {
    _timer?.cancel();
    _timer = null;
    _isRecording = false;
    try {
      await _recorder.cancel();
    } catch (_) {}
  }

  /// Yozilgan audioning baytlarini o'qiydi (yuborish uchun).
  Future<Uint8List> readBytes(String pathOrBlobUrl) =>
      readAudioBytes(pathOrBlobUrl);

  /// Vaqtinchalik audio faylni o'chiradi.
  Future<void> deleteRecording(String pathOrBlobUrl) =>
      deleteAudioFile(pathOrBlobUrl);

  /// Resurslarni tozalaydi.
  Future<void> dispose() async {
    _timer?.cancel();
    try {
      await _recorder.dispose();
    } catch (_) {}
    await _elapsedController.close();
  }
}
