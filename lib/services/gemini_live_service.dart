// Gemini Live (real-time ovozli AI) xizmati.
//
// Oqim: Worker proksi (Durable Object) → Gemini Live WS → setup (AUDIO,
// de-DE, system prompt) → mikrofon PCM (16kHz) oqimini yuborish → javob
// audiosini (PCM 24kHz) yig'ib, WAV qilib ijro etish.
//
// Worker Durable Object (DO) proksi ishlatadi — uzoq muddatli audio oqimi
// barqaror (1006/1011 xatolari yo'q). API kalit Worker'da saqlanadi.
//
// DIQQAT: Bu real-time audio oqimi platformaga bog'liq (ayniqsa web) —
// qurilmada/brauzerda test qilib, loglar bo'yicha to'g'irlash kerak.

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'pcm_player/pcm_player.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../widgets/ai_voice_face.dart';
import 'ai_service.dart';
import 'gemini_live_prompt.dart';
import 'dictionary_service.dart';

class GeminiLiveService {
  static const String _model = 'models/gemini-3.1-flash-live-preview';

  final AudioRecorder _recorder = AudioRecorder();
  final PcmPlayer _playerStream = getPcmPlayer();
  // Aksirish/yo'talish tovush effektlari uchun alohida player.
  final AudioPlayer _sfxPlayer = AudioPlayer();

  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  StreamSubscription<Uint8List>? _micSub;

  // Audio oqimi holati:
  DateTime? _expectedPlaybackEnd;

  // Mikrofon chunklarini 100ms da bir marta yuboramiz — WS xabarlar sonini
  // kamaytirish (Worker proksi va Gemini uchun barqarorroq).
  final BytesBuilder _pendingMic = BytesBuilder();
  Timer? _micFlushTimer;
  static const Duration _micFlushInterval = Duration(milliseconds: 100);

  bool _connected = false;
  bool _closed = false;
  bool _connecting = false;

  // Dastur tili — botning kirish so'zi va tushuntirishlari uchun.
  String _uiLangCode = 'uz';
  String? _customPersonality;
  String? _userName;
  VoiceAiMode _currentMode = VoiceAiMode.telc;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5; // 3 dan 5 ga oshirdik
  Timer? _reconnectTimer;
  Timer? _keepAliveTimer;
  static const Duration _keepAliveInterval = Duration(minutes: 5); // Har 5 daqiqada ping

  Timer? _usageTimer;
  int _usageTicks = 0; // For saving every 5 seconds
  static const int _dailyLimitSeconds = 1200; // 20 minutes
  /// Kunlik qolgan vaqt (soniyalarda).
  final ValueNotifier<int> remainingSeconds = ValueNotifier<int>(_dailyLimitSeconds);

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

  String? _dynamicTaskInstruction;

  /// Ulanadi va suhbatni boshlaydi.
  Future<void> connect({
    required String uiLangCode,
    required VoiceAiMode mode,
    String? customPersonality,
    String? userName,
    String? dynamicTaskInstruction,
  }) async {
    if (_connected || _connecting) return;
    _connecting = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      if (_channel != null) await disconnect();
      _uiLangCode = uiLangCode;
      _customPersonality = customPersonality;
      _userName = userName;
      _currentMode = mode;
      _dynamicTaskInstruction = dynamicTaskInstruction;
      _closed = false;
      state.value = AiFaceState.thinking; // "connecting"
      error.value = null;

      // Kunlik vaqtni tekshiramiz
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final prefs = await SharedPreferences.getInstance();
      final usedSeconds = prefs.getInt('voice_ai_usage_$today') ?? 0;
      
      if (usedSeconds >= _dailyLimitSeconds) {
        remainingSeconds.value = 0;
        error.value = "Bugungi 20 daqiqalik limitingiz tugadi. Ertaga yana urinib ko'ring!";
        state.value = AiFaceState.idle;
        return;
      }
      
      remainingSeconds.value = _dailyLimitSeconds - usedSeconds;

      try {
        await _playerStream.initialize(sampleRate: 24000);
        await _playerStream.start();
        
        // 1. Ephemeral token olamiz (API kalit xavfsizligi uchun)
        debugPrint('GeminiLive: Token olish so\'rovi yuborilmoqda...');
        final token = await AIService.fetchGeminiLiveToken();
        
        if (_closed) return;
        
        // 2. To'g'ridan-to'g'ri Google'ga ulanamiz (Worker proksi orqali emas,
        // chunki proksi ba'zan binary audio paketlarini o'tkazmaydi yoki kechiktiradi).
        debugPrint('GeminiLive: Google Live API\'ga to\'g\'ridan-to\'g\'ri ulanmoqda...');
        final wsUrl = AIService.liveDirectWebSocketUrl(token: token);
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

        _wsSub = _channel!.stream.listen(
          _onMessage,
          onError: (e) {
            debugPrint('GeminiLive WS error: $e');
            if (!_closed) _scheduleReconnect();
          },
          onDone: () {
            final code = _channel?.closeCode;
            final reason = _channel?.closeReason;
            debugPrint('GeminiLive WS closed (code=$code, reason=$reason)');
            _connected = false;
            if (!_closed) {
              // Avtomatik qayta ulanish kodlari:
              // 1006 = abnormal closure (tarmoq uzildi)
              // 1008 = policy violation / sessiya timeout (~10 daqiqa)
              // 1011 = server internal error
              // null = noma'lum (xavfsizlik uchun qayta ulanish)
              if (code == 1006 || code == 1008 || code == 1011 || code == null) {
                debugPrint(
                    'GeminiLive: $code xatosi — qayta ulanish urinilmoqda...');
                _scheduleReconnect(closeCode: code);
              } else {
                error.value = 'Ulanish yopildi (code=$code)';
                state.value = AiFaceState.idle;
              }
            }
          },
        );

        // Fetch dynamic glossary asynchronously from local dictionary
        final glossary = await KarakalpakDictionaryService().getGlossaryForMode(mode);

        const voiceName = 'Puck';

        final setup = {
          'setup': {
            'model': _model,
            'generationConfig': {
              'responseModalities': ['AUDIO'],
              'speechConfig': {
                'voiceConfig': {
                  'prebuiltVoiceConfig': {'voiceName': voiceName},
                },
              },
            },
            'realtimeInputConfig': {
              'automaticActivityDetection': {
                'disabled': false,
              },
            },
            'systemInstruction': {
              'parts': [
                {
                  'text': buildGeminiLivePrompt(
                    uiLangCode: uiLangCode,
                    mode: mode,
                    customPersonality: customPersonality,
                    userName: _userName,
                    dynamicGlossary: glossary,
                    dynamicTaskInstruction: _dynamicTaskInstruction,
                  )
                },
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
    } finally {
      _connecting = false;
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
        
        // Timer'ni boshlash
        _usageTimer?.cancel();
        _usageTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          if (!_connected) return;
          
          remainingSeconds.value--;
          _usageTicks++;
          
          if (remainingSeconds.value <= 0) {
            remainingSeconds.value = 0;
            final dateKey = DateTime.now().toIso8601String().substring(0, 10);
            final p = await SharedPreferences.getInstance();
            await p.setInt('voice_ai_usage_$dateKey', _dailyLimitSeconds);
            
            error.value = "Bugungi 20 daqiqalik limitingiz tugadi. Ertaga yana urinib ko'ring!";
            await disconnect();
            return;
          }

          // Har 5 soniyada xotiraga yozamiz
          if (_usageTicks >= 5) {
            _usageTicks = 0;
            final dateKey = DateTime.now().toIso8601String().substring(0, 10);
            final p = await SharedPreferences.getInstance();
            await p.setInt('voice_ai_usage_$dateKey', _dailyLimitSeconds - remainingSeconds.value);
          }
        });

        _startMic(); // mikrofon doim ochiq
        state.value = AiFaceState.thinking; // bot kirish so'zini tayyorlaydi
        _sendOpeningTrigger();
        _startKeepAlive(); // Keep-alive timerni ishga tushirish
        return;
      }

      final serverContent = msg['serverContent'] as Map<String, dynamic>?;
      if (serverContent != null) {
        // DEBUG: foydalanuvchi nutqi transkripsiyasi — model eshitayaptimi?
        final inT =
            serverContent['inputTranscription'] as Map<String, dynamic>?;
        if (inT != null && inT['text'] != null) {
          debugPrint('GeminiLive: USER dedi => "${inT['text']}"');
        }

        // AI javob matnini yig'amiz va emotsiyani JONLI (real-time) aniqlaymiz.
        // Emotsiya faqat oxirgi kelgan transkripsiya bo'lagi asosida aniqlanadi —
        // shu tarzda gap davomida emotsiya o'z vaqtida o'zgaradi (masalan,
        // "haha" paytida kuladi, keyin oddiy gapga o'tsa neutral'ga qaytadi).
        final outT =
            serverContent['outputTranscription'] as Map<String, dynamic>?;
        if (outT != null && outT['text'] != null) {
          String t = outT['text'] as String;
          _turnText.write(t);
          // Emotsiyani oxirgi 60 ta belgi (sliding window) asosida aniqlaymiz.
          // Shunda parchalangan so'zlar (masalan "ha" va "haha") to'g'ri o'qiladi, 
          // va ma'lum vaqt o'tgach yana neutral holatga qaytadi.
          if (state.value == AiFaceState.speaking) {
            final fullStr = _turnText.toString().toLowerCase();
            final window = fullStr.length > 60 ? fullStr.substring(fullStr.length - 60) : fullStr;
            emotion.value = _inferEmotion(window);
          }
        }

        // Model audio qismlarini yig'amiz.
        final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>?;
        if (modelTurn != null) {
          final parts = modelTurn['parts'] as List<dynamic>? ?? [];
          for (final p in parts) {
            final inline = (p as Map<String, dynamic>)['inlineData']
                as Map<String, dynamic>?;
            if (inline != null && inline['data'] != null) {
              final pcm = base64Decode(inline['data'] as String);
              _feedAudioChunk(pcm);
            }
          }
        }

        // Foydalanuvchi botni to'xtatdi (barge-in).
        if (serverContent['interrupted'] == true) {
          _playerStream.stop();
          _playerStream.initialize(sampleRate: 24000);
          _playerStream.start();
          _expectedPlaybackEnd = null;
          if (!_closed) state.value = AiFaceState.listening;
        }

        // Navbat tugadi.
        if (serverContent['turnComplete'] == true) {
          final fullText = _turnText.toString();
          final finalEmotion = _inferEmotion(fullText);
          _turnText.clear();
          
          final remaining = _expectedPlaybackEnd?.difference(DateTime.now()) ?? Duration.zero;
          
          void setDone() {
             if (_closed) return;
             if (_expectedPlaybackEnd != null && _expectedPlaybackEnd!.isAfter(DateTime.now())) return;
             state.value = AiFaceState.listening;
             emotion.value = AiFaceEmotion.neutral;
             mouthLevel.value = 0.0;
          }
          
          if (remaining.isNegative) {
            setDone();
          } else {
            emotion.value = finalEmotion;
            Timer(remaining, setDone);
          }
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
        if (!_connected || _closed) return;
        // Faqat AI gapirayotganda mikrofon ovozini yubormaymiz —
        // o'z ovozini qaytadan eshitib (echo), o'zini to'xtatib qo'yishini oldini oladi.
        // "thinking" paytida audio yuborishni davom ettiramiz — aks holda Gemini VAD
        // foydalanuvchining gapirib bo'lganini aniqlay olmaydi.
        if (state.value == AiFaceState.speaking) {
          return;
        }
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

  /// Keep-alive mexanizmi — har 5 daqiqada sessiyani faol saqlab turish uchun
  /// bo'sh xabar yuboradi (1008 timeout oldini olish).
  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(_keepAliveInterval, (_) {
      if (!_connected || _closed) {
        _keepAliveTimer?.cancel();
        return;
      }
      final ch = _channel;
      if (ch != null) {
        try {
          // Bo'sh clientContent yuborish — sessiyani faol tutadi
          ch.sink.add(jsonEncode({
            'clientContent': {
              'turns': [],
              'turnComplete': false,
            },
          }));
          debugPrint('GeminiLive: keep-alive ping yuborildi');
        } catch (e) {
          debugPrint('GeminiLive: keep-alive xatosi: $e');
        }
      }
    });
  }

  /// Bot gapirayotganda uni to'xtatish (barge-in) — foydalanuvchi tugmani
  /// bossa chaqiriladi. Mikrofon doim ochiq bo'lgani uchun ixtiyoriy.
  void interrupt() {
    if (!_connected || _closed) return;
    _playerStream.stop();
    _playerStream.initialize(sampleRate: 24000);
    _playerStream.start();
    _expectedPlaybackEnd = null;
    state.value = AiFaceState.listening;
  }



  /// 1006/1008/1011 xatolarida avtomatik qayta ulanish.
  /// 1008 (sessiya timeout) — darhol qayta ulanish (oddiy timeout).
  /// 1006/1011 — exponential backoff (2s, 4s, 6s).
  /// 5 ta urinishdan keyin muvaffaqiyatsiz bo'lsa xato ko'rsatadi.
  void _scheduleReconnect({int? closeCode}) {
    if (_closed) return;
    
    // 1008 uchun alohida hisoblagich — cheksiz qayta ulanish
    final isTimeout = closeCode == 1008;
    if (isTimeout) {
      // 1008 timeout uchun hisoblagichni nollaymiz
      _reconnectAttempts = 0;
    }
    
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('GeminiLive: qayta ulanish urinishlari tugadi.');
      error.value = 'Ulanish uzildi. Sahifani yangilang.';
      state.value = AiFaceState.idle;
      _reconnectAttempts = 0;
      return;
    }
    _reconnectAttempts++;
    // 1008 (sessiya timeout ~10 daqiqa) — oddiy timeout, darhol qayta ulanish.
    // 1006/1011 — xato, kechiktirish bilan qayta ulanish.
    final delay = isTimeout 
        ? const Duration(milliseconds: 500) // 0.5s — foydalanuvchi sezmaydi
        : Duration(seconds: _reconnectAttempts * 2); // 2s, 4s, 6s
    debugPrint(
        'GeminiLive: ${delay.inMilliseconds}ms dan keyin qayta ulanish (#$_reconnectAttempts, code=$closeCode)...');
    state.value = AiFaceState.thinking; // "qayta ulanmoqda..."
    error.value = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      if (_closed) return;
      // Eski kanallarni tozalaymiz, lekin _closed = false saqlaymiz.
      _connected = false;
      _expectedPlaybackEnd = null;
      _micFlushTimer?.cancel();
      _micFlushTimer = null;
      await _micSub?.cancel();
      _micSub = null;
      try {
        await _recorder.stop();
      } catch (_) {}
      await _wsSub?.cancel();
      _wsSub = null;
      _keepAliveTimer?.cancel();
      _keepAliveTimer = null;
      try {
        await _channel?.sink.close();
      } catch (_) {}
      _channel = null;
      try {
        await _playerStream.stop();
      } catch (_) {}
      // Qayta ulanish — connect() ni chaqiramiz.
      // _connecting bayrog'ini tozalaymiz, aks holda connect() darhol qaytib ketadi.
      _connecting = false;
      try {
        await connect(
          uiLangCode: _uiLangCode,
          mode: _currentMode,
          customPersonality: _customPersonality,
          userName: _userName,
        );
        // Muvaffaqiyatli ulangan bo'lsa hisoblagichni nollaymiz
        if (_connected) {
          _reconnectAttempts = 0;
        }
      } catch (e) {
        debugPrint('GeminiLive: qayta ulanish xatosi: $e');
        // Agar ulanish xato bo'lsa, yana bir bor harakat qilish
        if (!_closed && _reconnectAttempts < _maxReconnectAttempts) {
          _scheduleReconnect(closeCode: closeCode);
        }
      }
    });
  }

  bool _isAudioAboveThreshold(Uint8List chunk, int threshold) {
    // PCM 16-bit Mono: 2 bytes per sample.
    for (int i = 0; i < chunk.length - 1; i += 2) {
      int val = chunk[i] | (chunk[i + 1] << 8);
      if (val & 0x8000 != 0) {
        val -= 0x10000;
      }
      if (val.abs() > threshold) {
        return true;
      }
    }
    return false;
  }

  void _queueAudioChunk(Uint8List chunk) {
    if (state.value == AiFaceState.speaking) {
      _pendingMic.clear();
      return;
    }
    // Shovqin filtrini olib tashladik — Gemini'ning o'z VAD (automaticActivityDetection)
    // mexanizmi audio ichidagi nutqni va pauzalarni aniq aniqlaydi.
    // Client tarafda filtrlaganda Gemini serveriga yetarli audio yetib bormay,
    // nutq tugashini sezmay qolayotgan edi.
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
    // realtimeInput.audio — Gemini Live API uchun to'g'ri format
    ch.sink.add(jsonEncode({
      'realtimeInput': {
        'audio': {
          'mimeType': 'audio/pcm;rate=16000',
          'data': base64Encode(chunk),
        }
      }
    }));
    // DEBUG: mikrofon audio yuboryaptimi? Har ~50 bo'lakda bir marta.
    _sentChunks++;
    _sentBytes += chunk.length;
    if (_sentChunks % 50 == 0) {
      debugPrint('GeminiLive: mikrofon -> $_sentChunks bo\'lak, '
          '$_sentBytes bayt yuborildi');
    }
  }

  void _feedAudioChunk(Uint8List pcm) {
    if (state.value != AiFaceState.speaking) {
      state.value = AiFaceState.speaking;
      _pendingMic.clear(); // Residul audio tozalash
      // UI darhol yangilanishi uchun qo'shimcha xabar
      debugPrint("GeminiLive: Ovoz kelishni boshladi, state -> speaking");
    }
    _playerStream.writeChunk(pcm);

    final durationMs = (pcm.length / 48000 * 1000).toInt();
    final now = DateTime.now();
    final startPlayTime = _expectedPlaybackEnd != null && _expectedPlaybackEnd!.isAfter(now)
        ? _expectedPlaybackEnd!
        : now;
    
    _expectedPlaybackEnd = startPlayTime.add(Duration(milliseconds: durationMs));

    double sum = 0;
    int count = 0;
    for (int i = 0; i < pcm.length - 1; i += 2) {
      final sample = (pcm[i] | (pcm[i + 1] << 8)).toSigned(16);
      sum += sample * sample;
      count++;
    }
    final rms = count > 0 ? math.sqrt(sum / count) : 0;
    final level = (rms / 8000.0).clamp(0.0, 1.0);

    final delay = startPlayTime.difference(DateTime.now());
    if (delay.isNegative) {
      if (!_closed) mouthLevel.value = level;
    } else {
      Timer(delay, () {
        if (!_closed) mouthLevel.value = level;
      });
    }
  }

  /// Tovush effektini (aksirish/yo'talish) ijro etib, tugashini kutadi.
  /* 
  // Hozircha ishlatilmaydi — kelajakda reaktsiya uchun
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
  */

  /* Eski fart trigger funksiyasi — hozircha ishlatilmaydi.
  /// Fart effektini gapirish TUGAGANDAN KEYIN (gapning oxirida) ishga tushiradi.
  Future<void> _triggerFartAfterSpeech() async {
    if (_closed) return;

    // Avval SFX chaliladi.
    await _playSfx('sounds/Fart.mp3');
    if (_closed) return;

    // SFX tugagandan keyin AI ga reaktsiya buyrug'ini yuboramiz.
    final lang = _uiLangCode;
    final String reactPrompt;
    switch (lang) {
      case 'ru':
        reactPrompt =
            '(Только что произошёл неловкий звук — пукнул кто-то невидимый. '
            'Скажи по-русски смущённо и немного смешно что-то вроде: '
            '"Это точно был не я!" — и сразу же, если спросят кто — '
            'скажи что это был словарный запас ученика.)';
        break;
      case 'de':
        reactPrompt =
            '(Gerade ist ein peinliches Geräusch passiert — jemand unsichtbares. '
            'Sage auf Deutsch verlegen und leicht amüsiert: '
            '"Das war definitiv nicht ich!" — und falls gefragt wird wer es war: '
            'das war der Wortschatz des Lernenden.)';
        break;
      default:
        reactPrompt =
            "(Hozir noqulay bir tovush chiqdi — kimningdir ko'rinmas ishi. "
            "O'zbek tilida xijolat bilan va sal kulimsirab: "
            '"Bu men emas edi, 100 foiz!" — de, '
            "agar kim deb so'rasa: bu sening slovar zapasing edi de.)";
    }

    final ch = _channel;
    if (ch != null && !_closed) {
      ch.sink.add(jsonEncode({
        'clientContent': {
          'turns': [
            {
              'role': 'user',
              'parts': [
                {'text': reactPrompt}
              ]
            }
          ],
          'turnComplete': true,
        }
      }));
    }
  }
  */

  /// AI javob matnidan his-tuyg'uni taxminlaydi (kalit so'zlar bo'yicha).
  /// Faqat speaking holatida ko'rinadi — listening/thinking da neutral qoladi.
  AiFaceEmotion _inferEmotion(String text) {
    final t = text.toLowerCase();
    bool has(List<String> keys) => keys.any(t.contains);

    // Aksirish (Hatschi!) — faqat aksirish tovushi.
    if (has([
      'hatschi',
      'hatschie',
      'haptschi',
      'atschoo',
      'achoo',
      'apchxi',
      'апчхи',
      'aksirdim',
    ])) {
      return AiFaceEmotion.sneezing;
    }
    // Yo'talish.
    if (has([
      'hust hust',
      'hust,',
      'räusper',
      'raeusper',
      'khe-khe',
      'кхе-кхе',
      "yo'taldim",
    ])) {
      return AiFaceEmotion.coughing;
    }
    // Kulish.
    if (has(['haha', 'hah', 'lol', 'hehe', 'hihi'])) {
      return AiFaceEmotion.laughing;
    }
    // G'azab / baqirish — ANIQROQ va ko'proq kalit so'zlar.
    // Bot chindan ham asabiy, siljigan, baqiryotgan paytda.
    if (has([
      // Deutsch — qattiq/asabiy so'zlar
      'scheiße', 'scheisse', 'quatsch', 'mein gott', 'verdammt',
      'kindergarten', 'null punkte', '0 punkte', 'katastrophe',
      'schwachsinn', 'was soll das', 'unmöglich', 'peinlich',
      'schrecklich', 'erbärmlich', 'so ein chaos', 'das kann nicht',
      'nein nein nein', 'wie oft', 'zum letzten mal',
      // Русский — asabiy/siljigan
      'нет-нет-нет', 'что за бред', 'детский сад', 'позор',
      'сколько раз', 'до каких пор', 'блин', 'черт',
      // O'zbekcha — siljigan/asabiy
      "yo'q-yo'q-yo'q", 'kalla bormi', "to'nka", "bog'cha darajasi",
      'sharmanda', 'dahshat', 'uyat', 'qanaqasiga', 'necha marta',
      'qachongacha', 'miyangni ishlat', 'oyoqni qo\'y',
    ])) {
      return AiFaceEmotion.angry;
    }
    // Maqtov / xursandchilik.
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
      'ausgezeichnet',
      'fantastisch',
      'großartig',
      'отлично',
      'молодец',
      'правильно',
      'хорошо',
      'zo\'r',
      'barakalla',
      'to\'g\'ri',
      'ajoyib',
    ])) {
      return AiFaceEmotion.happy;
    }
    // Hayrat.
    if (has([
      'wow',
      'wirklich?',
      'echt?',
      'oh!',
      'oha',
      'krass',
      'действительно?',
      'правда?',
      'серьёзно?',
      'rostdanmi?',
      'voy',
    ])) {
      return AiFaceEmotion.surprised;
    }
    // Sad (xafa) emotsiyasi olib tashlandi — neutral qaytadi.
    // Sabab: "leider", "falsch", "nicht ganz" kabi so'zlar bot gapida
    // ko'p uchraydi, lekin bu xafa bo'lish emas — oddiy tuzatish.
    return AiFaceEmotion.neutral;
  }



  /// Suhbatni to'xtatadi va resurslarni tozalaydi.
  Future<void> disconnect() async {
    _closed = true;
    _connected = false;
    _connecting = false;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    state.value = AiFaceState.idle;
    emotion.value = AiFaceEmotion.neutral;
    _micFlushTimer?.cancel();
    _micFlushTimer = null;
    _pendingMic.clear();
    await _micSub?.cancel();
    _micSub = null;
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {}
    await _wsSub?.cancel();
    _wsSub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _expectedPlaybackEnd = null;
    try {
      await _playerStream.stop();
      _playerStream.dispose();
    } catch (_) {}
    try {
      await _sfxPlayer.stop();
    } catch (_) {}
  }

  void dispose() {
    _usageTimer?.cancel();
    disconnect();
    _recorder.dispose();
    _sfxPlayer.dispose();
    state.dispose();
    emotion.dispose();
    mouthLevel.dispose();
    error.dispose();
    remainingSeconds.dispose();
  }
}
