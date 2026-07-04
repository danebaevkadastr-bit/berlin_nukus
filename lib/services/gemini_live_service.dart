// Gemini Live (real-time ovozli AI) xizmati.
//
// Oqim: Worker'dan ephemeral token → to'g'ridan-to'g'ri Gemini Live WS → setup
// (AUDIO, de-DE, system prompt) → mikrofon PCM (16kHz) oqimini yuborish →
// javob audiosini (PCM 24kHz) yig'ib, WAV qilib ijro etish.
//
// Worker faqat token beradi; audio oqimi CF proksi orqali EMAS (1006 xatosi).
//
// DIQQAT: Bu real-time audio oqimi platformaga bog'liq (ayniqsa web) —
// qurilmada/brauzerda test qilib, loglar bo'yicha to'g'irlash kerak.

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../widgets/ai_voice_face.dart';
import 'ai_service.dart';
import 'gemini_live_prompt.dart';

class GeminiLiveService {
  static const String _model = 'models/gemini-3.1-flash-live-preview';

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  // Aksirish/yo'talish tovush effektlari uchun alohida player.
  final AudioPlayer _sfxPlayer = AudioPlayer();

  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  StreamSubscription<Uint8List>? _micSub;
  StreamSubscription<void>? _playerCompleteSub;

  // Turn audiosini yig'amiz, turnComplete da bitta WAV qilib ijro etamiz.
  // Birinchi audio kelganida darhol "speaking" animatsiyasiga o'tamiz
  // (og'iz qimirlaydi) — foydalanuvchi kutmaydi deb sezadi.
  final BytesBuilder _turnAudio = BytesBuilder();

  // Amplitude tracking uchun: ijro paytida raw PCM saqlash va timer.
  Uint8List? _playingPcm;
  int _playStartMs = 0;
  Timer? _ampTimer;

  // Mikrofon chunklarini 100ms da bir marta yuboramiz — WS xabarlar sonini
  // kamaytirish (Worker proksi va Gemini uchun barqarorroq).
  final BytesBuilder _pendingMic = BytesBuilder();
  Timer? _micFlushTimer;
  static const Duration _micFlushInterval = Duration(milliseconds: 100);

  bool _connected = false;
  bool _closed = false;

  // Dastur tili — botning kirish so'zi va tushuntirishlari uchun.
  String _uiLangCode = 'uz';

  /// Ekran kuzatadigan holat (yuz animatsiyasi uchun).
  final ValueNotifier<AiFaceState> state =
      ValueNotifier<AiFaceState>(AiFaceState.idle);

  /// Botning his-tuyg'usi — AI javob matnidan aniqlanadi.
  final ValueNotifier<AiFaceEmotion> emotion =
      ValueNotifier<AiFaceEmotion>(AiFaceEmotion.neutral);

  /// Joriy navbatdagi AI matni (output transcription) — emotsiya aniqlash uchun.
  final StringBuffer _turnText = StringBuffer();

  /// Og'iz ochilish darajasi (0.0–1.0) — audio amplitudasiga mos.
  final ValueNotifier<double> mouthLevel = ValueNotifier<double>(0.0);

  /// Xato xabari (ekranda ko'rsatish uchun).
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);

  /// Ulanadi va suhbatni boshlaydi.
  Future<void> connect({
    required String uiLangCode,
    String? customPersonality,
  }) async {
    if (_connected) return;
    if (_channel != null) await disconnect();
    _uiLangCode = uiLangCode;
    _closed = false;
    state.value = AiFaceState.thinking; // "connecting"
    error.value = null;

    try {
      // Worker'dan qisqa muddatli token olamiz, keyin to'g'ridan-to'g'ri
      // Gemini Live'ga ulanamiz (CF Worker WS proksi audio oqimida yiqiladi).
      debugPrint('GeminiLive: token olinmoqda...');
      final token = await AIService.fetchGeminiLiveToken();
      final wsUrl = AIService.liveDirectWebSocketUrl(token: token);
      debugPrint('GeminiLive: to\'g\'ridan-to\'g\'ri ulanmoqda...');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _wsSub = _channel!.stream.listen(
        _onMessage,
        onError: (e) {
          debugPrint('GeminiLive WS error: $e');
          error.value = 'Ulanishda xato: $e';
          state.value = AiFaceState.idle;
        },
        onDone: () {
          final code = _channel?.closeCode;
          final reason = _channel?.closeReason;
          debugPrint('GeminiLive WS closed (code=$code, reason=$reason)');
          _connected = false;
          if (!_closed) {
            error.value = 'Ulanish yopildi (code=$code, reason=$reason)';
            state.value = AiFaceState.idle;
          }
        },
      );

      // Setup xabari.
      final setup = {
        'setup': {
          'model': _model,
          'generationConfig': {
            'responseModalities': ['AUDIO'],
            'thinkingConfig': {
              'thinkingLevel': 'minimal',
            },
            'speechConfig': {
              'languageCode': 'de-DE',
              'voiceConfig': {
                'prebuiltVoiceConfig': {'voiceName': 'Puck'},
              },
            },
          },
          'realtimeInputConfig': {
            'automaticActivityDetection': {'disabled': false},
          },
          'systemInstruction': {
            'parts': [
              {'text': buildGeminiLivePrompt(
                uiLangCode: uiLangCode,
                customPersonality: customPersonality,
              )},
            ],
          },
          'inputAudioTranscription': <String, dynamic>{},
          'outputAudioTranscription': <String, dynamic>{},
        },
      };
      _channel!.sink.add(jsonEncode(setup));
    } catch (e) {
      debugPrint('GeminiLive connect error: $e');
      error.value = 'Ulanib bo\'lmadi';
      state.value = AiFaceState.idle;
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final String text;
      if (raw is String) {
        text = raw;
      } else if (raw is List<int>) {
        text = utf8.decode(raw);
      } else {
        return;
      }
      debugPrint('GeminiLive <= '
          '${text.length > 300 ? "${text.substring(0, 300)}..." : text}');
      final msg = jsonDecode(text) as Map<String, dynamic>;

      // Setup tugadi — mikrofon oqimini ochamiz (lekin audio faqat tugma
      // bosilganda yuboriladi), so'ng botni birinchi bo'lib gapirtiramiz.
      if (msg.containsKey('setupComplete')) {
        _connected = true;
        _startMic(); // mikrofon doim ochiq
        state.value = AiFaceState.thinking; // bot kirish so'zini tayyorlaydi
        _sendOpeningTrigger();
        return;
      }

      final serverContent = msg['serverContent'] as Map<String, dynamic>?;
      if (serverContent != null) {
        // DEBUG: foydalanuvchi nutqi transkripsiyasi — model eshitayaptimi?
        final inT = serverContent['inputTranscription'] as Map<String, dynamic>?;
        if (inT != null && inT['text'] != null) {
          debugPrint('GeminiLive: USER dedi => "${inT['text']}"');
        }

        // AI javob matnini yig'amiz va emotsiyani JONLI aniqlaymiz.
        final outT = serverContent['outputTranscription'] as Map<String, dynamic>?;
        if (outT != null && outT['text'] != null) {
          _turnText.write(outT['text']);
          final e = _inferEmotion(_turnText.toString());
          if (e != AiFaceEmotion.neutral) emotion.value = e;
        }

        // Model audio qismlarini yig'amiz.
        final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>?;
        if (modelTurn != null) {
          final parts = modelTurn['parts'] as List<dynamic>? ?? [];
          for (final p in parts) {
            final inline = (p as Map<String, dynamic>)['inlineData']
                as Map<String, dynamic>?;
            if (inline != null && inline['data'] != null) {
              // Audio yig'ilmoqda — "speaking" HOLATI faqat _playTurn'da
              // (haqiqiy ijro boshlanganda) qo'yiladi, shunda og'iz audio
              // bilan sinxron qimirlaydi.
              _turnAudio.add(base64Decode(inline['data'] as String));
            }
          }
        }

        // Foydalanuvchi botni to'xtatdi (barge-in).
        if (serverContent['interrupted'] == true) {
          _player.stop();
          _stopAmpTimer();
          _turnAudio.clear();
          if (!_closed) state.value = AiFaceState.listening;
        }

        // Navbat tugadi — yig'ilgan audioni bitta WAV qilib ijro etamiz.
        if (serverContent['turnComplete'] == true) {
          emotion.value = _inferEmotion(_turnText.toString());
          _turnText.clear();
          _playTurn();
        }
      }

      // Server xatosi (masalan, noto'g'ri audio format).
      final err = msg['error'] as Map<String, dynamic>?;
      if (err != null) {
        final msgText = err['message'] ?? err['status'] ?? err.toString();
        debugPrint('GeminiLive server error: $msgText');
        error.value = 'Server xato: $msgText';
      }
    } catch (e) {
      debugPrint('GeminiLive parse error: $e');
    }
  }

  Future<void> _startMic() async {
    try {
      final hasPerm = await _recorder.hasPermission();
      if (!hasPerm) {
        error.value = 'Mikrofon ruxsati yo\'q';
        return;
      }
      final stream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ));
      _micSub = stream.listen((chunk) {
        // Mikrofonni doim ochiq qoldiramiz (barge-in uchun).
        if (!_connected || _closed) return;
        _queueAudioChunk(chunk);
      });
    } catch (e) {
      debugPrint('GeminiLive mic error: $e');
      error.value = 'Mikrofonni ochib bo\'lmadi';
    }
  }

  /// Botni birinchi bo'lib gapirtiradi — salomlashib, bugun nima haqida
  /// gaplashishni so'raydi.
  void _sendOpeningTrigger() {
    final ch = _channel;
    if (ch == null) return;
    final trigger = buildGeminiLiveOpeningTrigger(uiLangCode: _uiLangCode);
    ch.sink.add(jsonEncode({
      'clientContent': {
        'turns': [
          {
            'role': 'user',
            'parts': [
              {'text': trigger},
            ],
          },
        ],
        'turnComplete': true,
      },
    }));
  }

  /// Bot gapirayotganda uni to'xtatish (barge-in) — foydalanuvchi tugmani
  /// bossa chaqiriladi. Mikrofon doim ochiq bo'lgani uchun ixtiyoriy.
  void interrupt() {
    if (!_connected || _closed) return;
    _player.stop();
    _stopAmpTimer();
    _turnAudio.clear();
    state.value = AiFaceState.listening;
  }

  void _queueAudioChunk(Uint8List chunk) {
    _pendingMic.add(chunk);
    _micFlushTimer ??= Timer(_micFlushInterval, _flushMicBuffer);
  }

  void _flushMicBuffer() {
    _micFlushTimer?.cancel();
    _micFlushTimer = null;
    if (!_connected || _closed) {
      _pendingMic.clear();
      return;
    }
    final chunk = _pendingMic.takeBytes();
    if (chunk.isEmpty) return;
    _sendAudioChunk(chunk);
  }

  int _sentChunks = 0;
  int _sentBytes = 0;
  void _sendAudioChunk(Uint8List chunk) {
    final ch = _channel;
    if (ch == null) return;
    // Let's use realtimeInput.mediaChunks
    final realtimeMsg = {
      'realtimeInput': {
        'mediaChunks': [
          {
            'mimeType': 'audio/pcm;rate=16000',
            'data': base64Encode(chunk),
          }
        ]
      },
    };
    ch.sink.add(jsonEncode(realtimeMsg));
    // DEBUG: mikrofon audio yuboryaptimi? Har ~50 bo'lakda bir marta.
    _sentChunks++;
    _sentBytes += chunk.length;
    if (_sentChunks % 50 == 0) {
      debugPrint('GeminiLive: mikrofon -> $_sentChunks bo\'lak, '
          '$_sentBytes bayt yuborildi');
    }
  }

  /// Yig'ilgan PCM'ni bitta WAV qilib ijro etadi (uzluksiz, bo'lib-bo'lib emas).
  /// Og'iz amplitudasi timer orqali real-time yangilanadi.
  Future<void> _playTurn() async {
    final pcm = _turnAudio.takeBytes();
    if (pcm.isEmpty) {
      state.value = AiFaceState.listening;
      return;
    }
    try {
      final wav = _pcm16ToWav(pcm, sampleRate: 24000, channels: 1);
      state.value = AiFaceState.speaking;

      // Aksirish/yo'talish emotsiyasi bo'lsa — avval real tovush effektini
      // ijro qilamiz (bot ovozidan oldin).
      final emo = emotion.value;
      if (emo == AiFaceEmotion.sneezing) {
        await _playSfx('sounds/sneeze.mp3');
      } else if (emo == AiFaceEmotion.coughing) {
        await _playSfx('sounds/cough.mp3');
      }
      if (_closed) return;

      // Amplitude tracking boshlash.
      _playingPcm = Uint8List.fromList(pcm);
      _playStartMs = DateTime.now().millisecondsSinceEpoch;
      _startAmpTimer();

      _playerCompleteSub ??= _player.onPlayerComplete.listen((_) {
        _stopAmpTimer();
        if (!_closed) {
          state.value = AiFaceState.listening;
          emotion.value = AiFaceEmotion.neutral;
          mouthLevel.value = 0.0;
        }
      });
      await _player.stop();
      await _player.play(BytesSource(wav));
    } catch (e) {
      debugPrint('GeminiLive play error: $e');
      _stopAmpTimer();
      state.value = AiFaceState.listening;
    }
  }

  /// Har 50ms PCM'dagi joriy pozitsiya amplitudasini o'lchab mouthLevel'ni
  /// yangilaydi — og'iz real audio balandligiga mos qimirlaydi.
  void _startAmpTimer() {
    _ampTimer?.cancel();
    _ampTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final pcm = _playingPcm;
      if (pcm == null || pcm.isEmpty) return;
      final elapsed = DateTime.now().millisecondsSinceEpoch - _playStartMs;
      // 24kHz, 16-bit mono: har millisekunda 24 * 2 = 48 bayt.
      final bytePos = (elapsed * 48).clamp(0, pcm.length - 2);
      // 512 sample oynada RMS hisoblaymiz.
      const window = 512 * 2; // baytlarda
      final end = (bytePos + window).clamp(0, pcm.length);
      double sum = 0;
      int count = 0;
      for (int i = bytePos; i < end - 1; i += 2) {
        final sample = (pcm[i] | (pcm[i + 1] << 8)).toSigned(16);
        sum += sample * sample;
        count++;
      }
      if (count == 0) return;
      final rms = math.sqrt(sum / count);
      // Normalize: 16-bit max ~32768, lekin odatiy gap ~3000-8000.
      final level = (rms / 8000.0).clamp(0.0, 1.0);
      mouthLevel.value = level;
    });
  }

  void _stopAmpTimer() {
    _ampTimer?.cancel();
    _ampTimer = null;
    _playingPcm = null;
    mouthLevel.value = 0.0;
  }

  /// Tovush effektini (aksirish/yo'talish) ijro etib, tugashini kutadi.
  Future<void> _playSfx(String assetPath) async {
    try {
      final done = _sfxPlayer.onPlayerComplete.first;
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
      await done.timeout(const Duration(seconds: 4), onTimeout: () {});
    } catch (e) {
      debugPrint('GeminiLive sfx error: $e');
    }
  }

  /// AI javob matnidan his-tuyg'uni taxminlaydi (oddiy kalit so'zlar bo'yicha).
  AiFaceEmotion _inferEmotion(String text) {
    final t = text.toLowerCase();
    bool has(List<String> keys) => keys.any(t.contains);

    // Aksirish (Hatschi!) — faqat aksirish tovushi, "Gesundheit" (o'rgatish
    // so'zi) EMAS.
    if (has([
      'hatschi', 'hatschie', 'haptschi', 'atschoo', 'achoo',
      'apchxi', 'апчхи', 'aksirdim',
    ])) {
      return AiFaceEmotion.sneezing;
    }
    // Yo'talish (Hust hust).
    if (has([
      'hust hust', 'hust,', 'räusper', 'raeusper', 'khe-khe', 'кхе-кхе',
      "yo'taldim",
    ])) {
      return AiFaceEmotion.coughing;
    }
    if (has(['haha', 'hah', 'lol', '😂', '😄', 'hehe'])) {
      return AiFaceEmotion.laughing;
    }
    // Jahl / qattiqqo'llik bilan dalda berish (baqirish effekti). FAQAT aniq,
    // uzun iboralar — umumiy so'zlar ("qani", "genau") YO'Q, aks holda oddiy
    // gapda ham qizarib ketadi.
    if (has([
      // Deutsch
      'streng dich an', 'das musst du wissen', 'wie willst du so',
      'nein, nein, nein', 'komm schon', 'gib dir mehr mühe',
      // Русский
      'ты должен это знать', 'как ты так', 'соберись', 'нет-нет-нет',
      // O'zbekcha
      'bilishing kerak', "o'zingni bos", "yo'q-yo'q-yo'q", 'qanaqasiga',
    ])) {
      return AiFaceEmotion.angry;
    }
    if (has([
      'super',
      'toll',
      'bravo',
      'sehr gut',
      'genau',
      'richtig',
      'perfekt',
      'klasse',
      'wunderbar',
      'gut gemacht',
      'prima',
    ])) {
      return AiFaceEmotion.happy;
    }
    if (has(['leider', 'schade', 'nicht ganz', 'nicht richtig', 'falsch'])) {
      return AiFaceEmotion.sad;
    }
    if (has(['wow', 'wirklich?', 'echt?', 'oh!', 'oha', 'krass'])) {
      return AiFaceEmotion.surprised;
    }
    return AiFaceEmotion.neutral;
  }

  /// PCM16 (mono) baytlarini ijro etiladigan WAV formatiga o'raydi.
  Uint8List _pcm16ToWav(Uint8List pcm,
      {int sampleRate = 24000, int channels = 1}) {
    final byteRate = sampleRate * channels * 2;
    final blockAlign = channels * 2;
    final dataLen = pcm.length;
    final b = BytesBuilder();
    void writeStr(String s) => b.add(s.codeUnits);
    void writeU32(int v) =>
        b.add([v & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >> 24) & 0xff]);
    void writeU16(int v) => b.add([v & 0xff, (v >> 8) & 0xff]);

    writeStr('RIFF');
    writeU32(36 + dataLen);
    writeStr('WAVE');
    writeStr('fmt ');
    writeU32(16);
    writeU16(1); // PCM
    writeU16(channels);
    writeU32(sampleRate);
    writeU32(byteRate);
    writeU16(blockAlign);
    writeU16(16); // bits per sample
    writeStr('data');
    writeU32(dataLen);
    b.add(pcm);
    return b.toBytes();
  }

  /// Suhbatni to'xtatadi va resurslarni tozalaydi.
  Future<void> disconnect() async {
    _closed = true;
    _connected = false;
    state.value = AiFaceState.idle;
    emotion.value = AiFaceEmotion.neutral;
    _micFlushTimer?.cancel();
    _micFlushTimer = null;
    _pendingMic.clear();
    await _micSub?.cancel();
    _micSub = null;
    try {
      await _recorder.stop();
    } catch (_) {}
    await _wsSub?.cancel();
    _wsSub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _turnAudio.clear();
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _sfxPlayer.stop();
    } catch (_) {}
  }

  void dispose() {
    disconnect();
    _stopAmpTimer();
    _playerCompleteSub?.cancel();
    _recorder.dispose();
    _player.dispose();
    _sfxPlayer.dispose();
    state.dispose();
    emotion.dispose();
    mouthLevel.dispose();
    error.dispose();
  }
}
