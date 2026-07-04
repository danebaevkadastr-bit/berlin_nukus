// STT → LLM → TTS ovozli suhbat pipeline.
//
// Mikrofon (record) → tugma qo'yilganda yozuv to'xtab, Groq Whisper (STT)
// orqali matnga → LLM (Cerebras/Qwen/Gemini, fallback) javob beradi →
// Amazon Polly (TTS) orqali audio ijro qilinadi.
//
// Gemini Live'dan farqi: har qadam eng tez provayderni ishlatadi, VAD
// muammosi yo'q (tugma = gapirish tugadi), ovoz sifati Polly Neural.

import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';

import '../widgets/ai_voice_face.dart';
import 'ai_service.dart';
import 'audio_recorder_platform.dart';
import 'audio_recorder_service.dart';
import 'gemini_live_prompt.dart';

class VoicePipelineService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final AudioRecorderService _audioHelper = AudioRecorderService.instance;

  static String get _proxyUrl => dotenv.env['CF_WORKER_URL']?.trim() ?? '';
  static String get _appToken => dotenv.env['APP_TOKEN']?.trim() ?? '';

  // Suhbat tarixi (LLM konteksti uchun).
  final List<Map<String, dynamic>> _history = [];

  // Dastur tili.
  String _uiLangCode = 'uz';
  // Foydalanuvchi kiritgan shaxsiyat sozlamalari.
  String? _customPersonality;

  StreamSubscription<void>? _playerCompleteSub;

  /// Ekran kuzatadigan holat.
  final ValueNotifier<AiFaceState> state =
      ValueNotifier<AiFaceState>(AiFaceState.idle);

  /// Emotsiya.
  final ValueNotifier<AiFaceEmotion> emotion =
      ValueNotifier<AiFaceEmotion>(AiFaceEmotion.neutral);

  /// Og'iz amplitudasi (TTS ijro paytida — hozircha soddalashtilgan).
  final ValueNotifier<double> mouthLevel = ValueNotifier<double>(0.0);

  /// Xato xabari.
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);

  bool _active = false;
  bool _recording = false;

  /// Sessiyani boshlaydi — bot birinchi gapiradi.
  Future<void> start({
    required String uiLangCode,
    String? customPersonality,
  }) async {
    _uiLangCode = uiLangCode;
    _customPersonality = customPersonality;
    _active = true;
    _history.clear();
    error.value = null;
    state.value = AiFaceState.thinking;

    _playerCompleteSub ??= _player.onPlayerComplete.listen((_) {
      mouthLevel.value = 0.0;
      if (_active) {
        state.value = AiFaceState.listening;
        emotion.value = AiFaceEmotion.neutral;
      }
    });

    // Bot birinchi gapiradi.
    final trigger = buildGeminiLiveOpeningTrigger(uiLangCode: _uiLangCode);
    await _generateAndSpeak(trigger);
    if (_active) state.value = AiFaceState.listening;
  }

  /// Mikrofon yozuvini boshlaydi (foydalanuvchi tugmani bosdi).
  Future<void> startRecording() async {
    if (!_active || _recording) return;
    // Bot gapirayotgan bo'lsa to'xtatamiz.
    await _player.stop();
    state.value = AiFaceState.listening;
    error.value = null;

    final hasPerm = await _recorder.hasPermission();
    if (!hasPerm) {
      error.value = 'Mikrofon ruxsati yo\'q';
      return;
    }
    _recording = true;

    final path = await newRecordingPath('voice_ai_${DateTime.now().millisecondsSinceEpoch}');
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
  }

  /// Mikrofon yozuvini to'xtatadi va pipeline'ni boshlaydi (STT→LLM→TTS).
  Future<void> stopRecordingAndProcess() async {
    if (!_active || !_recording) return;
    _recording = false;
    state.value = AiFaceState.thinking;

    try {
      final path = await _recorder.stop();
      if (path == null || path.isEmpty) {
        state.value = AiFaceState.listening;
        return;
      }

      // Baytlarni o'qish (web: blob URL, native: fayl yo'li).
      final audioBytes = await _audioHelper.readBytes(path);
      if (audioBytes.isEmpty) {
        state.value = AiFaceState.listening;
        return;
      }

      // 1) STT (Groq Whisper).
      final mimeType = kIsWeb ? 'audio/ogg' : 'audio/mp4';
      final userText = await AIService.transcribeAudio(
        audioBytes: audioBytes,
        mimeType: mimeType,
        language: 'de',
      );
      debugPrint('VoicePipeline STT: "$userText"');
      if (userText.trim().isEmpty) {
        state.value = AiFaceState.listening;
        return;
      }

      _history.add({'role': 'user', 'text': userText.trim()});

      // 2-3) LLM javob + TTS ijro.
      await _generateAndSpeak(userText.trim());
      if (_active) state.value = AiFaceState.listening;
    } catch (e) {
      debugPrint('VoicePipeline error: $e');
      error.value = 'Xato: $e';
      if (_active) state.value = AiFaceState.listening;
    }
  }

  /// LLM'dan javob olib, ElevenLabs TTS orqali ijro etadi.
  Future<void> _generateAndSpeak(String userMessage) async {
    state.value = AiFaceState.thinking;
    try {
      final systemPrompt = buildGeminiLivePrompt(
        uiLangCode: _uiLangCode,
        customPersonality: _customPersonality,
      );

      final reply = await AIService.sendMessage(
        message: userMessage,
        history: _history,
        context: systemPrompt,
      );
      debugPrint('VoicePipeline LLM: "$reply"');
      _history.add({'role': 'assistant', 'text': reply});

      // LLM javobidan markerlarni tozalaymiz (Worker ham tozalaydi, lekin
      // emotsiya aniqlash uchun asl matnni saqlaymiz, TTS uchun tozalaymiz).
      final cleanReply = _cleanForTts(reply);

      // Emotsiya aniqlash — asl matndan (markerlar bor bo'lishi mumkin).
      emotion.value = _inferEmotion(reply);

      // ElevenLabs TTS — tozalangan matn.
      state.value = AiFaceState.speaking;
      mouthLevel.value = 0.6;
      debugPrint('VoicePipeline: ElevenLabs TTS boshlanyapti...');
      await _speakWithElevenLabs(cleanReply);
    } catch (e) {
      debugPrint('VoicePipeline generate error: $e');
      error.value = '$e';
      mouthLevel.value = 0.0;
    }
  }

  /// Dastur tilini ElevenLabs til kodiga o'giradi. Uzbek ElevenLabs'da
  /// qo'llab-quvvatlanmaydi — bo'sh qaytaramiz (auto-detect).
  String _ttsLangCode() {
    switch (_uiLangCode) {
      case 'ru':
        return 'ru';
      case 'de':
        return 'de';
      case 'uz':
      case 'kaa':
      default:
        return ''; // ElevenLabs uzbekchani bilmaydi — auto-detect
    }
  }

  /// ElevenLabs TTS — Worker proksi orqali.
  Future<void> _speakWithElevenLabs(String text) async {
    if (_proxyUrl.isEmpty) {
      throw Exception('CF_WORKER_URL sozlanmagan');
    }
    final langCode = _ttsLangCode();
    final response = await http.post(
      Uri.parse(_proxyUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-Proxy-Target': 'elevenlabs-tts',
        if (_appToken.isNotEmpty) 'X-App-Token': _appToken,
      },
      body: jsonEncode({
        'text': text,
        if (langCode.isNotEmpty) 'languageCode': langCode,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('ElevenLabs TTS xato (${response.statusCode}): '
          '${response.body.length > 100 ? response.body.substring(0, 100) : response.body}');
    }

    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('audio')) {
      throw Exception('ElevenLabs kutilmagan javob: $contentType');
    }

    final bytes = response.bodyBytes;
    if (bytes.isEmpty) {
      throw Exception('ElevenLabs bo\'sh audio qaytardi');
    }

    // Ijro etish va tugashini kutish.
    final completer = Completer<void>();
    StreamSubscription<void>? sub;
    sub = _player.onPlayerComplete.listen((_) {
      if (!completer.isCompleted) completer.complete();
      sub?.cancel();
    });

    await _player.stop();
    await _player.play(BytesSource(bytes));
    await completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () {},
    );
    mouthLevel.value = 0.0;
    sub.cancel();
  }

  /// LLM javobidan TTS uchun yaroqsiz markerlarni tozalaydi.
  String _cleanForTts(String text) {
    return text
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')        // [baqirib], [krichit]...
        .replaceAll(RegExp(r'\([^)]{0,60}\)'), '')    // (po russki), (auf Deutsch)
        .replaceAll(RegExp(r'\*{1,3}([^*]+)\*{1,3}'), r'$1') // **bold**
        .replaceAll(RegExp(r'^#+\s+', multiLine: true), '')   // ## sarlavhalar
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
  }

  AiFaceEmotion _inferEmotion(String text) {
    final t = text.toLowerCase();
    bool has(List<String> keys) => keys.any(t.contains);

    if (has(['hatschi', 'haptschi', 'achoo', 'apchxi', 'aksirdim'])) {
      return AiFaceEmotion.sneezing;
    }
    if (has(['hust hust', 'hust,', 'räusper', 'khe-khe', "yo'taldim"])) {
      return AiFaceEmotion.coughing;
    }
    if (has(['haha', 'hah', 'hehe'])) return AiFaceEmotion.laughing;
    if (has([
      'streng dich an', 'das musst du wissen', 'wie willst du so',
      'nein, nein, nein', 'komm schon',
      'bilishing kerak', "o'zingni bos", "yo'q-yo'q-yo'q",
    ])) {
      return AiFaceEmotion.angry;
    }
    if (has([
      'super', 'toll', 'bravo', 'sehr gut', 'genau', 'perfekt',
      'richtig', 'gut gemacht', 'prima',
    ])) {
      return AiFaceEmotion.happy;
    }
    if (has(['leider', 'schade', 'nicht ganz', 'falsch'])) {
      return AiFaceEmotion.sad;
    }
    if (has(['wow', 'wirklich?', 'echt?', 'krass'])) {
      return AiFaceEmotion.surprised;
    }
    return AiFaceEmotion.neutral;
  }

  /// Sessiyani tugatadi.
  Future<void> stop() async {
    _active = false;
    _recording = false;
    state.value = AiFaceState.idle;
    emotion.value = AiFaceEmotion.neutral;
    mouthLevel.value = 0.0;
    try { await _recorder.stop(); } catch (_) {}
    try { await _player.stop(); } catch (_) {}
  }

  void dispose() {
    stop();
    _playerCompleteSub?.cancel();
    _recorder.dispose();
    _player.dispose();
    state.dispose();
    emotion.dispose();
    mouthLevel.dispose();
    error.dispose();
  }
}
