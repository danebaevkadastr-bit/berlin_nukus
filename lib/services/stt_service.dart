import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'ai_service.dart';
import 'audio_recorder_service.dart';

/// "AI bilan mashq" / Sprechen AI chat mikrofoni uchun nutqni matnga
/// aylantirish (STT).
///
/// Brauzer/qurilma STT'si (speech_to_text) o'rniga endi audio YOZIB OLINADI va
/// Cloudflare Worker orqali Groq Whisper'ga (whisper-large-v3, `de`) yuborilib
/// matnga aylantiriladi. Bu web va telefonda bir xil ishonchli ishlaydi va
/// nemischani yaxshi taniydi (brauzer tili/takrorlanish muammolari yo'q).
///
/// Ommaviy API o'zgarmagan: [startRecording], [stopAndTranscribe],
/// [onAmplitudeChanged], [dispose] — shuning uchun chaqiruvchi ekran (chat)
/// o'zgartirilmaydi.
class STTService {
  final AudioRecorderService _recorder = AudioRecorderService.instance;
  final _random = Random();

  bool _recording = false;
  RecordedAudio? _pendingAudio; // 240s'da avtomatik to'xtaganda saqlanadi

  /// Yozishni boshlaydi. Mikrofon ruxsatini tekshiradi/so'raydi.
  Future<bool> startRecording() async {
    _pendingAudio = null;
    try {
      final has = await _recorder.hasPermission();
      if (!has) {
        final result = await _recorder.requestPermission();
        if (result != MicPermissionResult.granted) {
          debugPrint('STT: mikrofon ruxsati berilmadi ($result)');
          return false;
        }
      }

      await _recorder.start(
        recordingName: 'chat_stt_${DateTime.now().millisecondsSinceEpoch}',
        onAutoStop: (audio) {
          // 4 daqiqada avtomatik to'xtadi — natijani saqlab qo'yamiz.
          _pendingAudio = audio;
          _recording = false;
        },
      );
      _recording = true;
      return true;
    } catch (e) {
      debugPrint('STT: yozishni boshlab bo\'lmadi: $e');
      _recording = false;
      return false;
    }
  }

  /// Yozishni to'xtatadi, audioni Whisper (Worker) orqali matnga aylantiradi
  /// va matnni qaytaradi. Xato yoki bo'sh bo'lsa '' qaytaradi.
  Future<String> stopAndTranscribe() async {
    _recording = false;
    RecordedAudio? audio;
    try {
      if (_recorder.isRecording) {
        audio = await _recorder.stop();
      } else {
        audio = _pendingAudio;
      }
    } catch (e) {
      debugPrint('STT: yozishni to\'xtatib bo\'lmadi: $e');
      audio = _pendingAudio;
    }
    _pendingAudio = null;

    if (audio == null || audio.pathOrBlobUrl.isEmpty) {
      debugPrint('STT: audio yo\'q');
      return '';
    }

    try {
      final bytes = await _recorder.readBytes(audio.pathOrBlobUrl);
      final text = await AIService.transcribeAudio(
        audioBytes: bytes,
        mimeType: audio.mimeType,
        language: 'de',
      );
      debugPrint('STT: transkripsiya: $text');
      return text.trim();
    } catch (e) {
      debugPrint('STT: transkripsiya xatosi: $e');
      return '';
    } finally {
      // Vaqtinchalik faylni tozalaymiz.
      _recorder.deleteRecording(audio.pathOrBlobUrl);
    }
  }

  /// Mikrofon halqasi animatsiyasi uchun amplituda oqimi. record paketining
  /// haqiqiy amplitudasi o'rniga tabiiy ko'rinadigan tebranish simulyatsiyasi.
  Stream<Amplitude> onAmplitudeChanged(Duration interval) async* {
    while (_recording) {
      await Future.delayed(interval);
      const baseLevel = -25.0;
      final variation = (_random.nextDouble() - 0.5) * 30;
      final db = (baseLevel + variation).clamp(-45.0, -5.0);
      yield Amplitude(current: db, max: db);
    }
  }

  /// Resurslarni tozalaydi. DIQQAT: [AudioRecorderService] — umumiy (singleton)
  /// va Sprechen yozuvi ham undan foydalanadi, shuning uchun uni bu yerda
  /// dispose QILMAYMIZ; faqat davom etayotgan yozuvni bekor qilamiz.
  void dispose() {
    _recording = false;
    if (_recorder.isRecording) {
      _recorder.cancel();
    }
  }
}

class Amplitude {
  final double current;
  final double max;

  const Amplitude({required this.current, required this.max});
}
