import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../l10n/locale_manager.dart';
import '../../services/ai_service.dart';
import '../../services/chat_progress_service.dart';
import '../../services/stt_service.dart';
import '../../services/tts_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/chat_theme.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/chat/selected_word_sheet.dart';
import '../../widgets/decorative_pattern_background.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/empty_state.dart';
import '../../l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  final String title;
  final String sourceType; // lesson | conversation
  final bool initiallyCompleted;

  const ChatScreen({
    super.key,
    required this.title,
    required this.sourceType,
    this.initiallyCompleted = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final STTService _sttService = STTService();
  final TTSService _ttsService = TTSService();

  final ValueNotifier<double> _micLevel = ValueNotifier<double>(0.02);

  StreamSubscription<Amplitude>? _amplitudeSubscription;

  bool _isTypingMode = false;
  bool _isSending = false;
  bool _isRecording = false;
  bool _lessonFinished = false;

  double _textSize = 15;
  double _ttsSpeed = 1.0;
  bool _autoReadAiReply = true;
  bool _openTranslationByDefault = false;
  bool _showCorrections = true;
  int _chatMessageLimit = ChatProgressService.maxChatMessageLimit;

  String _mentorName = 'Frau Schneider';
  String _mentorRole = 'AI Mentor • Online';

  final List<ChatMessageModel> _messages = [];

  static const List<_MentorData> _mentors = [
    _MentorData(
      name: 'Frau Schneider',
      role: 'AI Mentor • Online',
      voiceId: 'de-DE-ElkeNeural',
      gradient: [Color(0xFF15B9FF), Color(0xFF7AF29A)],
    ),
    _MentorData(
      name: 'Herr Müller',
      role: 'AI Mentor • Online',
      voiceId: 'de-DE-ConradNeural',
      gradient: [Color(0xFF3C8CE7), Color(0xFF00EAFF)],
    ),
    _MentorData(
      name: 'Frau Fischer',
      role: 'AI Mentor • Online',
      voiceId: 'de-DE-KatjaNeural',
      gradient: [Color(0xFFFF8A65), Color(0xFFFFD54F)],
    ),
    _MentorData(
      name: 'Herr Becker',
      role: 'AI Mentor • Online',
      voiceId: 'de-DE-KillianNeural',
      gradient: [Color(0xFF8E54E9), Color(0xFF4776E6)],
    ),
  ];

  static const String _chatRules = '''
QOIDALAR (qat'iy):
- Hech qanday emoji, smaylik ishlatma.
- Har javobda faqat BITTA savol ber — bir nechta savol bir vaqtda berma.
- Javob qisqa bo'lsin: 2-4 gap.
- Faqat berilgan mavzu bo'yicha gapir.
- Avvalgi savollarga qaytma, takrorlanma.
- Asosan nemis tilida yoz; kerak bo'lsa 1 qator o'zbekcha yordam.
''';

  String get _contextPrompt {
    final totalLimit = ChatProgressService.maxUserMessagesPerTopic;
    final remaining = totalLimit - _userMessageCount;

    if (widget.sourceType == 'lesson') {
      return '''
Sen nemis tili o'qituvchisisan. Mavzu: "${widget.title}".

$_chatRules

DARS USLUBI:
- Faqat "${widget.title}" bo'yicha o'rgat: aniq lug'at, 1 grammatika nuqtasi, 1 misol gap.
- Har javobda: qisqa tushuntirish + 1 amaliy savol yoki mashq.
- Mavzuni qayta e'lon qilma.

LIMIT: Foydalanuvchida $remaining ta xabar qoldi (jami $totalLimit).
Agar 1-2 xabar qolsa, darsni yakunla: o'quvchini maqta, qisqacha xulosa chiqar va "Lektion beendet" deb yoz.
''';
    }

    return '''
Sen nemis tili suhbat mentorisiz. Mavzu: "${widget.title}".

$_chatRules

SUHBAT USLUBI:
- Faqat "${widget.title}" haqida aniq savol-javob.
- Har javobda 1 ta konkret savol ber.
- Uzun dars bermay, suhbat qil.

LIMIT: Foydalanuvchida $remaining ta xabar qoldi (jami $totalLimit).
Agar 1-2 xabar qolsa, suhbatni yakunla: o'quvchini maqta, qisqacha xulosa chiqar va "Lektion beendet" deb yoz.
''';
  }

  _MentorData get _currentMentor {
    return _mentors.firstWhere(
      (m) => m.name == _mentorName,
      orElse: () => _mentors.first,
    );
  }

  bool get _isFreeChat => widget.title.startsWith('Erkin suhbat');

  int get _userMessageCount =>
      _messages.where((m) => m.isUser && !m.isTyping).length;

  @override
  void initState() {
    super.initState();
    _ttsService.onPlaybackStateChanged = () {
      if (mounted) setState(() {});
    };
    _bootstrapSession();
  }

  Future<void> _bootstrapSession() async {
    _chatMessageLimit = await ChatProgressService.getChatMessageLimit();

    final completed = await ChatProgressService.isCompleted(
      widget.sourceType,
      widget.title,
    );
    final saved = await ChatProgressService.loadMessages(
      widget.sourceType,
      widget.title,
    );

    _lessonFinished =
        widget.initiallyCompleted || (!_isFreeChat && completed);

    if (saved.isNotEmpty) {
      _messages
        ..clear()
        ..addAll(saved.map(ChatMessageModel.fromMap));
      _updateReplyHintVisibility();
    } else if (!_lessonFinished) {
      _addInitialMessage();
      await _persistMessages();
    }

    if (mounted) setState(() {});
  }

  Future<void> _persistMessages() async {
    final maps = _messages
        .where((m) => !m.isTyping)
        .map((m) => m.toMap())
        .toList();
    await ChatProgressService.saveMessages(
      widget.sourceType,
      widget.title,
      maps,
    );
  }

  Future<void> _markSessionFinished() async {
    if (_isFreeChat || _lessonFinished) return;
    setState(() => _lessonFinished = true);
    await ChatProgressService.markCompleted(widget.sourceType, widget.title);
    await _persistMessages();
    _scrollToBottom(force: true);
  }

  void _checkMessageLimitCompletion() {
    if (_isFreeChat || _lessonFinished) return;
    // Limit yetganda AI javobidan keyin yakunlanadi (_checkLessonCompletion orqali)
    // Bu yerda faqat input bloklanadi
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _micLevel.dispose();
    _sttService.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  /// Dars tugashini tekshirish
  void _checkLessonCompletion(String aiResponse) {
    if (widget.sourceType != 'lesson' && widget.sourceType != 'conversation') return;
    if (_lessonFinished) return;

    // AI tugatish iboralari
    final completionKeywords = [
      'Lektion beendet',
      'Du hast die Lektion abgeschlossen',
      'Lektion abgeschlossen',
    ];

    final aiSaysFinished = completionKeywords.any(
      (keyword) => aiResponse.contains(keyword),
    );

    // Limit yetdi yoki AI yakunladi
    final limitReached =
        _userMessageCount >= ChatProgressService.maxUserMessagesPerTopic;

    if (aiSaysFinished || limitReached) {
      _markSessionFinished();
    }
  }

  /// Faqat oxirgi AI xabarida lampochka ko'rinishi uchun
  void _updateReplyHintVisibility() {
    int lastAiIndex = -1;
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (!_messages[i].isUser && !_messages[i].isTyping) {
        lastAiIndex = i;
        break;
      }
    }
    for (int i = 0; i < _messages.length; i++) {
      if (!_messages[i].isUser &&
          !_messages[i].isTyping &&
          _messages[i].showReplyHint != (i == lastAiIndex)) {
        _messages[i] = _messages[i].copyWith(showReplyHint: i == lastAiIndex);
      }
    }
  }

  void _addInitialMessage() {
    _messages.clear();

    final intro = 'Hallo! Heute sprechen wir über "${widget.title}".\nBist du bereit?';

    _messages.add(
      ChatMessageModel(
        id: 'ai_initial_${DateTime.now().microsecondsSinceEpoch}',
        text: intro,
        isUser: false,
        showTts: true,
        showTranslate: true,
        showReplyHint: true,
        translationVisible: _openTranslationByDefault,
      ),
    );

    _scrollToBottom(animated: false);
  }

  Future<void> _restartLesson() async {
    await ChatProgressService.clearCompleted(
      widget.sourceType,
      widget.title,
    );
    await ChatProgressService.clearMessages(widget.sourceType, widget.title);
    setState(() => _lessonFinished = false);
    _addInitialMessage();
    await _persistMessages();
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> _historyForBackend() {
    final all = _messages
        .where((m) => !m.isTyping)
        .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'text': m.text})
        .toList();
    return ChatProgressService.trimHistoryByMessageLimit(all, _chatMessageLimit);
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return true;
    final pos = _scrollController.position;
    return pos.maxScrollExtent - pos.pixels < 120;
  }

  void _scrollToBottom({bool animated = true, bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (!force && !_isNearBottom) return;
      final offset = _scrollController.position.maxScrollExtent + 140;
      if (animated) {
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(offset);
      }
    });
  }

  void _toggleTypingMode() {
    setState(() {
      _isTypingMode = !_isTypingMode;
    });

    if (_isTypingMode) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;
    if (!_isFreeChat && _lessonFinished) return;
    if (!_isFreeChat &&
        _userMessageCount >= ChatProgressService.maxUserMessagesPerTopic) {
      return;
    }

    final userId = 'u_${DateTime.now().microsecondsSinceEpoch}';
    final typingId = 't_${DateTime.now().microsecondsSinceEpoch}';

    setState(() {
      _isSending = true;
      _messages.add(ChatMessageModel(id: userId, text: trimmed, isUser: true));
      _messages.add(
        ChatMessageModel(id: typingId, text: '', isUser: false, isTyping: true),
      );
    });

    _textController.clear();
    _scrollToBottom(force: true);
    _checkMessageLimitCompletion();

    try {
      final reply = await AIService.sendMessage(
        message: trimmed,
        history: _historyForBackend(),
        context: _contextPrompt,
      );

      if (!mounted) return;

      final aiId = 'a_${DateTime.now().microsecondsSinceEpoch}';

      setState(() {
        _messages.removeWhere((m) => m.id == typingId);
        _messages.add(
          ChatMessageModel(
            id: aiId,
            text: reply,
            isUser: false,
            showTts: true,
            showTranslate: true,
            showReplyHint: true,
            translationVisible: _openTranslationByDefault,
          ),
        );
        _updateReplyHintVisibility();
      });

      _scrollToBottom(force: true);

      _checkLessonCompletion(reply);
      _checkMessageLimitCompletion();
      await _persistMessages();

      if (_autoReadAiReply) {
        Future.microtask(() => _handleTts(aiId));
      }

      if (_showCorrections) {
        Future.microtask(() => _runCorrection(userId));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.id == typingId);
        _messages.add(
          ChatMessageModel(
            id: 'e_${DateTime.now().microsecondsSinceEpoch}',
            text: 'Kechirasiz, hozir javob bera olmadim. $e',
            isUser: false,
          ),
        );
      });
      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  String get _targetLang {
    final code = LocaleManager.currentLocale.value.code;
    if (code == 'ru') return 'ru';
    return 'uz'; // uz, kaa, de hammasi uchun o'zbek
  }

  Future<void> _runCorrection(String messageId) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final text = _messages[index].text;

    try {
      final result = await AIService.checkMistakes(
        text: text,
        targetLang: _targetLang,
      );

      final hasMistake = result['hasMistake'] == true;
      if (!hasMistake || !mounted) return;

      final mistakesRaw = result['mistakes'] as List<dynamic>? ?? [];
      final mistakes = mistakesRaw
          .map(
            (e) =>
                CorrectionMistake.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

      setState(() {
        _messages[index] = _messages[index].copyWith(
          hasCorrection: true,
          correctionVisible: false,
          correction: CorrectionData(
            originalText: text,
            correctedText: (result['correctedText'] ?? '').toString(),
            explanationUz: (result['explanationUz'] ?? '').toString(),
            mistakes: mistakes,
          ),
        );
      });
    } catch (_) {}
  }

  Future<void> _toggleTranslation(String messageId) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final msg = _messages[index];

    if ((msg.translation ?? '').isNotEmpty) {
      setState(() {
        _messages[index] = msg.copyWith(
          translationVisible: !msg.translationVisible,
        );
      });
      return;
    }

    setState(() {
      _messages[index] = msg.copyWith(isTranslating: true);
    });

    try {
      final translated = await AIService.translateGermanText(
        text: msg.text,
        targetLang: _targetLang,
      );
      if (!mounted) return;
      setState(() {
        _messages[index] = msg.copyWith(
          translation: translated,
          translationVisible: true,
          isTranslating: false,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages[index] = msg.copyWith(isTranslating: false);
      });
    }
  }

  Future<void> _toggleHints(String messageId) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final msg = _messages[index];

    if (msg.replyHints.isNotEmpty) {
      setState(() {
        _messages[index] = msg.copyWith(
          replyHintsVisible: !msg.replyHintsVisible,
        );
      });
      return;
    }

    setState(() {
      _messages[index] = msg.copyWith(isLoadingHints: true);
    });

    try {
      final hints = await AIService.getReplyHints(
        context: '${widget.title}\nAI: ${msg.text}',
      );

      if (!mounted) return;
      setState(() {
        _messages[index] = msg.copyWith(
          replyHints: hints,
          replyHintsVisible: true,
          isLoadingHints: false,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages[index] = msg.copyWith(isLoadingHints: false);
      });
    }
  }

  void _toggleCorrectionCard(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final msg = _messages[index];
    if (!msg.hasCorrection || msg.correction == null) return;

    setState(() {
      _messages[index] = msg.copyWith(
        correctionVisible: !msg.correctionVisible,
      );
    });
  }

  Future<void> _handleTts(String messageId) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final msg = _messages[index];

    if (_ttsService.isPlaying && _ttsService.currentText == msg.text) {
      await _ttsService.stop();
      if (!mounted) return;
      setState(() {});
      return;
    }

    try {
      await _ttsService.play(
        text: msg.text,
        voiceId: _currentMentor.voiceId,
        rateValue: _ttsSpeed,
      );
      if (!mounted) return;
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _handleMicTap() async {
    if (!_isFreeChat && _lessonFinished) return;

    if (_isRecording) {
      // Stop recording
      _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;

      final text = await _sttService.stopAndTranscribe();
      if (!mounted) return;
      
      setState(() {
        _isRecording = false;
      });
      _micLevel.value = 0.02;

      if (text.trim().isNotEmpty) {
        setState(() {
          _isTypingMode = true;
          _textController.text = text;
        });
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) _focusNode.requestFocus();
        });
      }
      return;
    }

    // Start recording
    setState(() {
      _isRecording = true; // Set immediately for UI feedback
    });

    final ok = await _sttService.startRecording();
    if (!mounted) return;

    if (!ok) {
      // Recording failed to start
      setState(() {
        _isRecording = false;
      });
      _micLevel.value = 0.02;
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).microphoneError),
            backgroundColor: AppColors.duoRed,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Start amplitude animation
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = _sttService
        .onAmplitudeChanged(const Duration(milliseconds: 120))
        .listen(
          (amp) {
            if (!mounted) return;
            
            final db = amp.current;
            double normalized;

            if (db <= -45) {
              normalized = 0.04;
            } else if (db >= -5) {
              normalized = 1.0;
            } else {
              normalized = ((db + 45) / 40).clamp(0.04, 1.0);
            }

            // Boost lower levels for better visual effect
            final boosted = math.pow(normalized, 0.65).toDouble() * 1.25;
            _micLevel.value = boosted.clamp(0.08, 1.0);
          },
          onError: (error) {
            debugPrint('Amplitude stream error: $error');
          },
          onDone: () {
            debugPrint('Amplitude stream done');
            if (mounted) {
              _micLevel.value = 0.02;
            }
          },
        );
  }

  Future<void> _showSettings() async {
    final colors = ChatTheme.of(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        double tempTextSize = _textSize;
        double tempTtsSpeed = _ttsSpeed;
        bool tempAutoRead = _autoReadAiReply;
        bool tempOpenTranslation = _openTranslationByDefault;
        bool tempShowCorrections = _showCorrections;
        double tempChatWordLimit = _chatMessageLimit.toDouble();

        return StatefulBuilder(
          builder: (context, setModal) {
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 46,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(sheetContext).settings,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: Text(AppLocalizations.of(sheetContext).close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SettingsSlider(
                        title: AppLocalizations.of(sheetContext).textSize,
                        value: tempTextSize,
                        min: 13,
                        max: 22,
                        valueText: tempTextSize.toStringAsFixed(0),
                        onChanged: (v) => setModal(() => tempTextSize = v),
                      ),
                      const SizedBox(height: 10),
                      _SettingsSlider(
                        title: AppLocalizations.of(sheetContext).playbackSpeed,
                        value: tempTtsSpeed,
                        min: 0.6,
                        max: 1.3,
                        valueText: tempTtsSpeed.toStringAsFixed(1),
                        onChanged: (v) => setModal(() => tempTtsSpeed = v),
                      ),
                      const SizedBox(height: 10),
                      _SettingsSwitch(
                        title: AppLocalizations.of(sheetContext).autoReadAi,
                        value: tempAutoRead,
                        onChanged: (v) => setModal(() => tempAutoRead = v),
                      ),
                      _SettingsSwitch(
                        title: AppLocalizations.of(sheetContext).openTranslationDefault,
                        value: tempOpenTranslation,
                        onChanged: (v) =>
                            setModal(() => tempOpenTranslation = v),
                      ),
                      _SettingsSwitch(
                        title: AppLocalizations.of(sheetContext).showCorrections,
                        value: tempShowCorrections,
                        onChanged: (v) =>
                            setModal(() => tempShowCorrections = v),
                      ),
                      const SizedBox(height: 10),
                      _SettingsSlider(
                        title: AppLocalizations.of(sheetContext).chatLength,
                        value: tempChatWordLimit,
                        min: ChatProgressService.minChatMessageLimit.toDouble(),
                        max: ChatProgressService.maxChatMessageLimit.toDouble(),
                        divisions: ChatProgressService.maxChatMessageLimit -
                            ChatProgressService.minChatMessageLimit,
                        valueText: AppLocalizations.of(sheetContext).chatMessageLimit(
                          tempChatWordLimit.round(),
                          ChatProgressService.maxChatMessageLimit,
                        ),
                        onChanged: (v) =>
                            setModal(() => tempChatWordLimit = v),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final limit = tempChatWordLimit.round();
                            await ChatProgressService.setChatMessageLimit(limit);
                            setState(() {
                              _textSize = tempTextSize;
                              _ttsSpeed = tempTtsSpeed;
                              _autoReadAiReply = tempAutoRead;
                              _openTranslationByDefault = tempOpenTranslation;
                              _showCorrections = tempShowCorrections;
                              _chatMessageLimit = limit;
                            });
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          },
                          child: Text(AppLocalizations.of(sheetContext).save),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showMentorPicker() async {
    final colors = ChatTheme.of(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mentor tanlang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._mentors.map(
                  (mentor) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        await _ttsService.stop();
                        if (!mounted) return;
                        setState(() {
                          _mentorName = mentor.name;
                          _mentorRole = mentor.role;
                        });
                        _addInitialMessage();
                        _persistMessages();
                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: mentor.gradient,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mentor.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mentor.role,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.duoGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_mentorName == mentor.name)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.duoBlue,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSelectedWord(String word) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SelectedWordSheet(word: word),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ChatTheme.of(context);
    final isDark = ThemeManager.isDark;

    final showSessionActions = !_isFreeChat && _lessonFinished;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.textPrimary,
            size: 22,
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.title.toUpperCase(),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          if (showSessionActions)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.duoGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.duoGreen, width: 1.5),
                  ),
                  child: const Text(
                    'TUGALLANGAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.duoGreen,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            onPressed: _showSettings,
            icon: Icon(Icons.tune_rounded, color: colors.textPrimary),
          ),
        ],
      ),
      body: DecorativePatternBackground(
        isDark: isDark,
        variant: DecorativePatternVariant.derDieDas,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: GamifiedCard(
                  color: isDark
                      ? AppColors.duoCardGray.withValues(alpha: 0.12)
                      : Colors.white,
                  shadowColor:
                      isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                  shadowDepth: 5,
                  padding: const EdgeInsets.all(12),
                  onTap: _showMentorPicker,
                  child: Row(
                    children: [
                      GamifiedCard(
                        color: _currentMentor.gradient.first,
                        shadowColor: _currentMentor.gradient.last,
                        shadowDepth: 3,
                        borderRadius: 18,
                        padding: const EdgeInsets.all(10),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _mentorName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _mentorRole,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.duoGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.swap_horiz_rounded,
                        color: colors.textSecondary,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
              child: _messages.isEmpty
                  ? const NoMessagesEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];

                        return _ChatBubble(
                          message: message,
                          textSize: _textSize,
                          colors: colors,
                          isSpeaking:
                              _ttsService.isPlaying &&
                              _ttsService.currentText == message.text,
                          onTapWord: message.isUser ? null : _openSelectedWord,
                          onTapHint: message.showReplyHint
                              ? () => _toggleHints(message.id)
                              : null,
                          onTapTranslate: message.showTranslate
                              ? () => _toggleTranslation(message.id)
                              : null,
                          onTapTts: message.showTts
                              ? () => _handleTts(message.id)
                              : null,
                          onTapCorrection: message.hasCorrection
                              ? () => _toggleCorrectionCard(message.id)
                              : null,
                          onHintSelected: (hint) => _sendMessage(hint),
                        );
                      },
                    ),
            ),
            if (showSessionActions)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: GamifiedCard(
                        color: isDark
                            ? AppColors.duoCardGray.withValues(alpha: 0.15)
                            : Colors.white,
                        shadowColor: AppColors.duoBlueShadow,
                        shadowDepth: 4,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        onTap: () => Navigator.pop(context),
                        child: const Center(
                          child: Text(
                            'TUGATISH',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.duoBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GamifiedCard(
                        color: AppColors.duoGreen,
                        shadowColor: AppColors.duoGreenShadow,
                        shadowDepth: 4,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        onTap: _restartLesson,
                        child: const Center(
                          child: Text(
                            'QAYTA',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _BottomBar(
              controller: _textController,
              focusNode: _focusNode,
              isTypingMode: _isTypingMode,
              isSending: _isSending,
              isRecording: _isRecording,
              inputEnabled: _isFreeChat || !_lessonFinished,
              micLevel: _micLevel,
              onToggleMode: _toggleTypingMode,
              onSend: () => _sendMessage(_textController.text),
              onMicTap: _handleMicTap,
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isTypingMode;
  final bool isSending;
  final bool isRecording;
  final bool inputEnabled;
  final ValueNotifier<double> micLevel;
  final VoidCallback onToggleMode;
  final VoidCallback onSend;
  final VoidCallback onMicTap;

  const _BottomBar({
    required this.controller,
    required this.focusNode,
    required this.isTypingMode,
    required this.isSending,
    required this.isRecording,
    required this.inputEnabled,
    required this.micLevel,
    required this.onToggleMode,
    required this.onSend,
    required this.onMicTap,
  });

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(_BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_pulse.isAnimating) {
      _pulse.repeat();
    } else if (!widget.isRecording && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.reset();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ChatTheme.of(context);
    final isDark = ThemeManager.isDark;

    final voiceHeight = widget.isRecording ? 148.0 : 100.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: ValueListenableBuilder<double>(
        valueListenable: widget.micLevel,
        builder: (context, micLevel, child) {
          final glow = widget.isRecording ? (0.15 + micLevel * 0.45) : 0.0;
          final glowColor = Color.lerp(AppColors.duoBlue, AppColors.duoRed, micLevel)!;

          return GamifiedCard(
            color: isDark
                ? AppColors.duoCardGray.withValues(alpha: 0.12)
                : Colors.white,
            shadowColor: widget.isRecording
                ? glowColor.withValues(alpha: 0.35 + glow)
                : (isDark ? Colors.black26 : AppColors.duoCardGrayShadow),
            shadowDepth: widget.isRecording ? 4 + micLevel * 5 : 5,
            padding: EdgeInsets.fromLTRB(
              12,
              widget.isTypingMode ? 10 : 10,
              12,
              10,
            ),
            child: child!,
          );
        },
        child: SizedBox(
          height: widget.isTypingMode ? 54 : voiceHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                bottom: widget.isTypingMode ? 0 : 8,
                child: _IconBtn(
                  icon: widget.isTypingMode
                      ? Icons.mic_none_rounded
                      : Icons.keyboard_alt_outlined,
                  onTap: widget.inputEnabled ? widget.onToggleMode : null,
                  bg: AppColors.duoBlue,
                  iconColor: Colors.white,
                  borderColor: Colors.transparent,
                  size: 52,
                ),
              ),
              if (widget.isTypingMode)
                Positioned(
                  left: 60,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    height: 52,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            focusNode: widget.focusNode,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => widget.onSend(),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context).typeHere,
                              hintStyle:
                                  TextStyle(color: colors.textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                        GamifiedCard(
                          color: AppColors.duoGreen,
                          shadowColor: AppColors.duoGreenShadow,
                          shadowDepth: 3,
                          borderRadius: 14,
                          padding: const EdgeInsets.all(10),
                          onTap: widget.inputEnabled && !widget.isSending
                              ? widget.onSend
                              : null,
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Positioned.fill(
                  child: _VoiceMicPanel(
                    isRecording: widget.isRecording,
                    inputEnabled: widget.inputEnabled,
                    micLevel: widget.micLevel,
                    pulse: _pulse,
                    onTap: widget.onMicTap,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mikrofon atrofida ovoz balandligiga qarab o'zgaruvchi halqalar va to'lqinlar.
class _VoiceMicPanel extends StatelessWidget {
  final bool isRecording;
  final bool inputEnabled;
  final ValueNotifier<double> micLevel;
  final Animation<double> pulse;
  final VoidCallback onTap;

  const _VoiceMicPanel({
    required this.isRecording,
    required this.inputEnabled,
    required this.micLevel,
    required this.pulse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: micLevel,
      builder: (context, raw, _) {
        final level = isRecording ? (0.25 + raw * 0.75) : 0.0;
        final accent = Color.lerp(AppColors.duoBlue, AppColors.duoRed, level)!;

        return Stack(
          alignment: Alignment.center,
          children: [
            if (isRecording)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: RadialGradient(
                      center: const Alignment(0, 0.35),
                      radius: 1.1,
                      colors: [
                        accent.withValues(alpha: 0.35 * level),
                        accent.withValues(alpha: 0.08 * level),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 6,
              left: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: pulse,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(17, (i) {
                      // Create more dynamic wave effect
                      final phaseShift = i * 0.42;
                      final wave = isRecording
                          ? (math.sin(pulse.value * math.pi * 2 + phaseShift) + 1) / 2
                          : 0.12;
                      
                      // Add secondary wave for more complexity
                      final secondaryWave = isRecording
                          ? (math.sin(pulse.value * math.pi * 3 + phaseShift * 1.5) + 1) / 2
                          : 0.0;
                      
                      final combinedWave = (wave * 0.7 + secondaryWave * 0.3);
                      
                      final h = isRecording
                          ? 10 + level * 46 * (0.3 + 0.7 * combinedWave)
                          : 8.0;
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 45),
                        width: 4,
                        height: h.clamp(8, 52),
                        decoration: BoxDecoration(
                          color: accent.withValues(
                            alpha: isRecording ? 0.45 + level * 0.55 : 0.25,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 4,
              child: GestureDetector(
                onTap: inputEnabled ? onTap : null,
                child: SizedBox(
                  width: 130 + level * 60,
                  height: 78 + level * 20,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isRecording) ...[
                        // Outer ring - subtle pulse
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 88 + level * 52,
                          height: 88 + level * 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: (0.12 + level * 0.1) * 0.35),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.12 + level * 0.1),
                              width: 1.5,
                            ),
                          ),
                        ),
                        // Middle ring - medium pulse
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: 72 + level * 40,
                          height: 72 + level * 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: (0.2 + level * 0.15) * 0.35),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.2 + level * 0.15),
                              width: 2 + level * 2,
                            ),
                          ),
                        ),
                        // Inner ring - strong pulse
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: 58 + level * 28,
                          height: 58 + level * 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: (0.35 + level * 0.25) * 0.35),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.35 + level * 0.25),
                              width: 2.5 + level * 3,
                            ),
                          ),
                        ),
                      ],
                      Transform.scale(
                        scale: 1.0 + level * 0.14,
                        child: GamifiedCard(
                          color: isRecording
                              ? AppColors.duoRed
                              : AppColors.duoBlue,
                          shadowColor: isRecording
                              ? AppColors.duoRedShadow
                              : AppColors.duoBlueShadow,
                          shadowDepth: 5 + level * 3,
                          borderRadius: 99,
                          padding: const EdgeInsets.all(20),
                          child: Icon(
                            isRecording
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ... (qolgan classlar _ChatBubble, _LabeledText, _WordText, _IconBtn, _Dot, _SettingsSlider, _SettingsSwitch, _MentorData, CorrectionData, CorrectionMistake, ChatMessageModel o'zgarishsiz)

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final double textSize;
  final ChatTheme colors;
  final bool isSpeaking;
  final ValueChanged<String>? onTapWord;
  final VoidCallback? onTapHint;
  final VoidCallback? onTapTranslate;
  final VoidCallback? onTapTts;
  final VoidCallback? onTapCorrection;
  final ValueChanged<String>? onHintSelected;

  const _ChatBubble({
    required this.message,
    required this.textSize,
    required this.colors,
    required this.isSpeaking,
    this.onTapWord,
    this.onTapHint,
    this.onTapTranslate,
    this.onTapTts,
    this.onTapCorrection,
    this.onHintSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    if (message.isTyping) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Align(
          alignment: Alignment.centerLeft,
          child: GamifiedCard(
            color: isDark
                ? AppColors.duoCardGray.withValues(alpha: 0.12)
                : Colors.white,
            shadowColor:
                isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
            shadowDepth: 4,
            borderRadius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: const SizedBox(
              width: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Dot(color: AppColors.duoBlue),
                  _Dot(color: AppColors.duoGreen),
                  _Dot(color: AppColors.duoOrange),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser) ...[
                Column(
                  children: [
                    if (message.showTts)
                      _IconBtn(
                        icon: isSpeaking
                            ? Icons.stop_rounded
                            : Icons.volume_up_rounded,
                        onTap: onTapTts,
                      ),
                    if (message.showTts && message.showTranslate)
                      const SizedBox(height: 8),
                    if (message.showTranslate)
                      _IconBtn(
                        icon: message.isTranslating
                            ? Icons.hourglass_top_rounded
                            : Icons.translate_rounded,
                        onTap: onTapTranslate,
                      ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 270),
                child: message.isUser
                    ? GamifiedCard(
                        color: AppColors.duoGreen,
                        shadowColor: AppColors.duoGreenShadow,
                        shadowDepth: 4,
                        borderRadius: 20,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            fontSize: textSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.32,
                          ),
                        ),
                      )
                    : GamifiedCard(
                        color: isDark
                            ? AppColors.duoCardGray.withValues(alpha: 0.12)
                            : Colors.white,
                        shadowColor: isDark
                            ? Colors.black26
                            : AppColors.duoCardGrayShadow,
                        shadowDepth: 4,
                        borderRadius: 20,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: _WordText(
                          text: message.text,
                          fontSize: textSize,
                          color: colors.textPrimary,
                          onTapWord: onTapWord,
                        ),
                      ),
              ),
            ],
          ),
          if (message.isUser && message.hasCorrection)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: _IconBtn(
                  icon: Icons.lightbulb_outline_rounded,
                  onTap: onTapCorrection,
                  iconColor: AppColors.duoOrange,
                ),
              ),
            ),
          if ((message.translation ?? '').isNotEmpty &&
              message.translationVisible)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: message.isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 270),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.hintBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.hintBorder),
                  ),
                  child: Text(
                    message.translation!,
                    style: TextStyle(
                      fontSize: textSize - 1,
                      color: colors.hintText,
                      height: 1.32,
                    ),
                  ),
                ),
              ),
            ),
          if (!message.isUser && message.showReplyHint)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: _IconBtn(
                  icon: message.isLoadingHints
                      ? Icons.hourglass_top_rounded
                      : Icons.lightbulb_outline_rounded,
                  onTap: onTapHint,
                  iconColor: AppColors.duoOrange,
                ),
              ),
            ),
          if (message.replyHintsVisible && message.replyHints.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.replyHints
                    .map(
                      (hint) => InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: onHintSelected == null
                            ? null
                            : () => onHintSelected!(hint),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: colors.hintBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: colors.hintBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  hint,
                                  style: TextStyle(
                                    fontSize: textSize - 1,
                                    color: colors.hintText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: AppColors.duoOrange,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (message.correctionVisible && message.correction != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 285),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xato topildi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _LabeledText(
                      label: 'Xato gap',
                      value: message.correction!.originalText,
                      colors: colors,
                    ),
                    const SizedBox(height: 8),
                    _LabeledText(
                      label: 'To‘g‘rilangani',
                      value: message.correction!.correctedText,
                      colors: colors,
                    ),
                    if (message.correction!.explanationUz.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _LabeledText(
                        label: 'Izoh',
                        value: message.correction!.explanationUz,
                        colors: colors,
                      ),
                    ],
                    if (message.correction!.mistakes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Xatolar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...message.correction!.mistakes.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• ${m.wrong} → ${m.correct}\n  ${m.reasonUz}',
                            style: TextStyle(
                              fontSize: textSize - 2,
                              color: colors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LabeledText extends StatelessWidget {
  final String label;
  final String value;
  final ChatTheme colors;

  const _LabeledText({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 13,
          height: 1.35,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _WordText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final ValueChanged<String>? onTapWord;

  const _WordText({
    required this.text,
    required this.fontSize,
    required this.color,
    this.onTapWord,
  });

  @override
  Widget build(BuildContext context) {
    final parts = text.split(RegExp(r'(\s+)'));
    final spans = <InlineSpan>[];

    String clean(String w) =>
        w.replaceAll(RegExp(r'[^\p{L}ÄÖÜäöüß-]', unicode: true), '');

    for (final part in parts) {
      if (part.isEmpty) continue;
      if (part.trim().isEmpty) {
        spans.add(
          TextSpan(
            text: part,
            style: TextStyle(fontSize: fontSize, color: color, height: 1.32),
          ),
        );
      } else {
        final c = clean(part);
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: c.isEmpty || onTapWord == null
                  ? null
                  : () => onTapWord!(c),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                child: Text(
                  part,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: color,
                    height: 1.32,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? bg;
  final Color? iconColor;
  final Color? borderColor;
  final double size;

  const _IconBtn({
    required this.icon,
    this.onTap,
    this.bg,
    this.iconColor,
    this.borderColor,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ChatTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg ?? colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor ?? colors.border),
          ),
          child: Icon(icon, color: iconColor ?? colors.textSecondary, size: 20),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: 4, backgroundColor: color);
  }
}

class _SettingsSlider extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final String valueText;
  final ValueChanged<double> onChanged;
  final int? divisions;

  const _SettingsSlider({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.valueText,
    required this.onChanged,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ChatTheme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(valueText, style: TextStyle(color: colors.textSecondary)),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ChatTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _MentorData {
  final String name;
  final String role;
  final String voiceId;
  final List<Color> gradient;

  const _MentorData({
    required this.name,
    required this.role,
    required this.voiceId,
    required this.gradient,
  });
}

class CorrectionData {
  final String originalText;
  final String correctedText;
  final String explanationUz;
  final List<CorrectionMistake> mistakes;

  const CorrectionData({
    required this.originalText,
    required this.correctedText,
    required this.explanationUz,
    required this.mistakes,
  });
}

class CorrectionMistake {
  final String wrong;
  final String correct;
  final String reasonUz;

  const CorrectionMistake({
    required this.wrong,
    required this.correct,
    required this.reasonUz,
  });

  factory CorrectionMistake.fromMap(Map<String, dynamic> map) {
    return CorrectionMistake(
      wrong: (map['wrong'] ?? '').toString(),
      correct: (map['correct'] ?? '').toString(),
      reasonUz: (map['reasonUz'] ?? '').toString(),
    );
  }
}

class ChatMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final bool isTyping;

  final bool showTts;
  final bool showTranslate;
  final bool showReplyHint;

  final bool hasCorrection;
  final bool correctionVisible;
  final CorrectionData? correction;

  final String? translation;
  final bool translationVisible;
  final bool isTranslating;

  final List<String> replyHints;
  final bool replyHintsVisible;
  final bool isLoadingHints;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    this.isTyping = false,
    this.showTts = false,
    this.showTranslate = false,
    this.showReplyHint = false,
    this.hasCorrection = false,
    this.correctionVisible = false,
    this.correction,
    this.translation,
    this.translationVisible = false,
    this.isTranslating = false,
    this.replyHints = const [],
    this.replyHintsVisible = false,
    this.isLoadingHints = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'showTts': showTts,
        'showTranslate': showTranslate,
        'showReplyHint': showReplyHint,
        'translation': translation,
        'translationVisible': translationVisible,
      };

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: (map['id'] ?? '').toString(),
      text: (map['text'] ?? '').toString(),
      isUser: map['isUser'] == true,
      showTts: map['showTts'] == true,
      showTranslate: map['showTranslate'] == true,
      showReplyHint: map['showReplyHint'] == true,
      translation: map['translation']?.toString(),
      translationVisible: map['translationVisible'] == true,
    );
  }

  ChatMessageModel copyWith({
    String? id,
    String? text,
    bool? isUser,
    bool? isTyping,
    bool? showTts,
    bool? showTranslate,
    bool? showReplyHint,
    bool? hasCorrection,
    bool? correctionVisible,
    CorrectionData? correction,
    String? translation,
    bool? translationVisible,
    bool? isTranslating,
    List<String>? replyHints,
    bool? replyHintsVisible,
    bool? isLoadingHints,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isTyping: isTyping ?? this.isTyping,
      showTts: showTts ?? this.showTts,
      showTranslate: showTranslate ?? this.showTranslate,
      showReplyHint: showReplyHint ?? this.showReplyHint,
      hasCorrection: hasCorrection ?? this.hasCorrection,
      correctionVisible: correctionVisible ?? this.correctionVisible,
      correction: correction ?? this.correction,
      translation: translation ?? this.translation,
      translationVisible: translationVisible ?? this.translationVisible,
      isTranslating: isTranslating ?? this.isTranslating,
      replyHints: replyHints ?? this.replyHints,
      replyHintsVisible: replyHintsVisible ?? this.replyHintsVisible,
      isLoadingHints: isLoadingHints ?? this.isLoadingHints,
    );
  }
}
