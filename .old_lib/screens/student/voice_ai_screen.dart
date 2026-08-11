// Ovozli AI (STT→LLM→TTS pipeline) ekrani.
//
// Foydalanuvchi tugmani bosib turib gapiradi → qo'yib yuborgach STT→LLM→TTS
// pipeline ishlaydi → bot Amazon Polly orqali javob beradi.

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../core/providers/user_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/locale_manager.dart';
import '../../services/gemini_live_service.dart';
import '../../services/gemini_live_prompt.dart';
import '../../services/student_results_service.dart';
import '../../services/vocabulary_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../services/ai_service.dart';
import '../../widgets/sprechen_evaluation_dialog.dart';
import 'sprechen/sprechen_data.dart';
import '../../widgets/ai_voice_face.dart';

class VoiceAiScreen extends StatefulWidget {
  final String? initialTaskInstruction;
  final String? initialTaskTitle;
  final VoiceAiMode? initialMode;
  final SprechenAufgabe? initialAufgabe;
  final String? teilTitle;
  final int? teilNumber;

  const VoiceAiScreen({
    super.key,
    this.initialTaskInstruction,
    this.initialTaskTitle,
    this.initialMode,
    this.initialAufgabe,
    this.teilTitle,
    this.teilNumber,
  });

  @override
  State<VoiceAiScreen> createState() => _VoiceAiScreenState();
}

class _VoiceAiScreenState extends State<VoiceAiScreen>
    with SingleTickerProviderStateMixin {
  final GeminiLiveService _service = GeminiLiveService();
  bool _active = false;

  VoiceAiMode _selectedMode = VoiceAiMode.telc;
  String? _activeTaskTitle;
  String? _activeTaskInstruction;
  SprechenAufgabe? _activeAufgabe;
  String? _activeTeilTitle;
  int? _activeTeilNumber;
  bool _isTaskExpanded = false;

  Timer? _taskTimer;
  int? _taskRemainingSeconds;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // Foydalanuvchi kiritgan AI shaxsiyat sozlamalari (persistent).
  String _customPersonality = '';
  final TextEditingController _personalityCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialMode != null) {
      _selectedMode = widget.initialMode!;
    }
    _activeTaskTitle = widget.initialTaskTitle;
    _activeTaskInstruction = widget.initialTaskInstruction;
    _activeAufgabe = widget.initialAufgabe;
    _activeTeilTitle = widget.teilTitle;
    _activeTeilNumber = widget.teilNumber;

    _loadPersonality();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _service.state.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _stopTaskTimer();
    _pulseCtrl.dispose();
    _service.dispose();
    _personalityCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPersonality() async {
    // SharedPreferences orqali saqlanadi.
    final prefs = await _getPrefs();
    final saved = prefs.getString('voice_ai_personality') ?? '';
    setState(() => _customPersonality = saved);
    _personalityCtrl.text = saved;
  }

  Future<void> _savePersonality(String value) async {
    _customPersonality = value;
    final prefs = await _getPrefs();
    await prefs.setString('voice_ai_personality', value);
  }

  Future<SharedPreferences> _getPrefs() async {
    return SharedPreferences.getInstance();
  }

  String _statusText(AppLocalizations l, AiFaceState s) {
    if (!_active) return l.voiceAiTapToStart;
    if (s == AiFaceState.speaking) return l.voiceAiSpeaking;
    if (s == AiFaceState.thinking) return l.voiceAiThinking;
    return l.voiceAiListening;
  }

  bool _hasTriggeredWrapUp = false;

  int? _getTaskDurationSeconds() {
    if (_activeAufgabe == null && _activeTaskTitle == null && _activeTaskInstruction == null) {
      return null;
    }
    final num = _activeTeilNumber ?? widget.teilNumber;
    if (num == 1) return 180; // Teil 1: 3 daqiqa
    if (num == 2) return 240; // Teil 2: 4 daqiqa
    if (num == 3) return 240; // Teil 3: 4 daqiqa

    final teilTitle = (_activeTeilTitle ?? '').toLowerCase();
    final taskTitle = (_activeTaskTitle ?? '').toLowerCase();
    if (teilTitle.contains('1') || teilTitle.contains('vorstellen') || taskTitle.contains('vorstellen')) {
      return 180; // Teil 1: 3 daqiqa
    }
    if (teilTitle.contains('2') || taskTitle.contains('thema')) {
      return 240; // Teil 2: 4 daqiqa
    }
    if (teilTitle.contains('3') || teilTitle.contains('planen') || taskTitle.contains('planen')) {
      return 240; // Teil 3: 4 daqiqa
    }
    return 240; // Default 4 daqiqa
  }

  void _sendWrapUpPrompt() {
    final num = _activeTeilNumber ?? widget.teilNumber;
    final teilTitle = (_activeTeilTitle ?? '').toLowerCase();
    final taskTitle = (_activeTaskTitle ?? '').toLowerCase();

    String wrapUpPrompt;
    if (num == 1 || teilTitle.contains('1') || teilTitle.contains('vorstellen') || taskTitle.contains('vorstellen')) {
      wrapUpPrompt = 'SYSTEM-HINWEIS: Die 3 Minuten Vorstellungszeit sind fast um (nur noch 8 Sekunden)! Beende jetzt sofort höflich und natürlich unser Gespräch auf Deutsch als Prüfungspartner. Sag z.B. "Schön dich kennenzulernen! Unsere Zeit ist um, vielen Dank und viel Erfolg!"';
    } else if (num == 2 || teilTitle.contains('2') || taskTitle.contains('thema')) {
      wrapUpPrompt = 'SYSTEM-HINWEIS: Die 4 Minuten Präsentationszeit sind fast um (nur noch 8 Sekunden)! Beende jetzt sofort unser Gespräch auf Deutsch als Prüfungspartner. Bedanke dich für meine Meinung/Präsentation, z.B. "Vielen Dank für deine interessante Präsentation und Meinung! Wir haben das Thema gut besprochen. Danke dir!"';
    } else if (num == 3 || teilTitle.contains('3') || teilTitle.contains('planen') || taskTitle.contains('planen')) {
      wrapUpPrompt = 'SYSTEM-HINWEIS: Die 4 Minuten Planungszeit sind fast um (nur noch 8 Sekunden)! Beende jetzt sofort unser Gespräch auf Deutsch als Planungspartner. Bestätige den gemeinsamen Plan, z.B. "Perfekt, dann steht unser Plan! Wir haben alle Punkte besprochen. Ich freue mich schon, bis dann!"';
    } else {
      wrapUpPrompt = 'SYSTEM-HINWEIS: Die Übungszeit ist fast um (nur noch 8 Sekunden)! Beende jetzt sofort unser Gespräch höflich und natürlich auf Deutsch als Prüfungspartner.';
    }

    _service.sendTextPrompt(wrapUpPrompt);
  }

  void _startTaskTimer() {
    _stopTaskTimer();
    final duration = _getTaskDurationSeconds();
    if (duration == null) return;

    _hasTriggeredWrapUp = false;
    _taskRemainingSeconds = duration;
    _taskTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_taskRemainingSeconds != null && _taskRemainingSeconds! > 0) {
          _taskRemainingSeconds = _taskRemainingSeconds! - 1;
          if (_taskRemainingSeconds == 8 && !_hasTriggeredWrapUp) {
            _hasTriggeredWrapUp = true;
            _sendWrapUpPrompt();
          }
        } else {
          _stopTaskTimer();
          _endSession();
        }
      });
    });
  }

  void _stopTaskTimer() {
    _taskTimer?.cancel();
    _taskTimer = null;
  }

  Future<void> _connect() async {
    setState(() => _active = true);
    _startTaskTimer();
    final userProv = context.read<UserProvider>();
    final userName = userProv.name; // fullName dan birinchi so'z
    final uid = userProv.firebaseUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      StudentResultsService.saveVoiceAiUsage(uid: uid, mode: _selectedMode.name);
    }

    String? taskInstruction = _activeTaskInstruction;
    if (_selectedMode == VoiceAiMode.lugat) {
      final savedWords = await VocabularyService.getSavedWords();
      final activeWords = savedWords.where((w) => !w.isMastered).toList();
      if (activeWords.isNotEmpty) {
        final wordsStr = activeWords.take(30).map((w) {
          final tr = w.meanings.firstOrNull?.translation ?? '';
          return 'Wort: "${w.germanWord}" (Übersetzung: "$tr")';
        }).join('; ');
        taskInstruction = 'VOKABELLISTE DES NUTZERS ZUM PRÜFEN: [$wordsStr]. Prüfe den Nutzer nacheinander zu diesen genauen Wörtern! Achte darauf, dass der Nutzer in seiner Sprache (Karakalpakisch, Russisch oder Usbekisch) mit der angegebenen Übersetzung antwortet.';
      }
    }

    await _service.connect(
      uiLangCode: LocaleManager.code,
      mode: _selectedMode,
      customPersonality:
          _customPersonality.isNotEmpty ? _customPersonality : null,
      userName: userName.isNotEmpty ? userName : null,
      dynamicTaskInstruction: taskInstruction,
    );
  }

  Future<void> _endSession() async {
    _stopTaskTimer();
    final transcriptCopy = List<Map<String, String>>.from(_service.sessionTranscript);
    final userSpoke = transcriptCopy.any((t) => t['speaker'] == 'User');

    await _service.disconnect();
    if (mounted) {
      setState(() {
        _active = false;
      });
    }

    if (userSpoke && (_activeAufgabe != null || _activeTaskTitle != null)) {
      _evaluateSession(transcriptCopy);
    }
  }

  void _evaluateSession(List<Map<String, String>> history) {
    final title = _activeAufgabe?.title ?? _activeTaskTitle ?? 'Sprechen Mashqi';
    final teilTitle = _activeTeilTitle ?? 'TELC Sprechen';
    final teilNumber = _activeTeilNumber ?? widget.teilNumber ?? 2;

    final evalFuture = AIService.evaluateLiveSprechenSession(
      taskTitle: title,
      teilTitle: teilTitle,
      teilNumber: teilNumber,
      level: 'B1',
      history: history,
      uiLangCode: LocaleManager.code,
    );

    SprechenEvaluationDialog.show(
      context: context,
      taskTitle: title,
      teilTitle: teilTitle,
      teilNumber: teilNumber,
      level: 'B1',
      evaluationFuture: evalFuture,
      onRetry: () => _connect(),
    );
  }

  void _showPersonalityDialog() {
    _personalityCtrl.text = _customPersonality;
    final isUz = LocaleManager.code == 'uz';
    final title = isUz ? 'Ovozli botni sozlash' : 'AI-Bot anpassen';
    final hint = isUz
        ? 'Masalan: "Sen xatolarni doim kulgili ohangda tushuntiradigan hazilkashsan..."'
        : 'z.B.: "Du bist ein lustiger Typ..."';
    final cancel = isUz ? 'Bekor' : 'Abbrechen';
    final save = isUz ? 'Saqlash' : 'Speichern';

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = ThemeManager.isDark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF131F24) : Colors.white,
          title: Text(title,
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.duoTextDark, 
                  fontSize: 16)),
          content: TextField(
            controller: _personalityCtrl,
            maxLines: 6,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.duoTextDark, 
                fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : AppColors.duoTextLight, 
                  fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? Colors.white24 : AppColors.duoCardGrayShadow),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.duoBlue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(cancel, 
                  style: TextStyle(
                      color: isDark ? Colors.white54 : AppColors.duoTextLight)),
            ),
            TextButton(
              onPressed: () {
                _savePersonality(_personalityCtrl.text.trim());
                Navigator.pop(ctx);
              },
              child: Text(save, style: const TextStyle(color: AppColors.duoBlue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ValueListenableBuilder<AccentPreset>(
      valueListenable: ThemeManager.accentNotifier,
      builder: (context, _, __) {
        final isDark = ThemeManager.isDark;
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
          body: SafeArea(
            child: Column(
              children: [
                // Yuqori panel.
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: isDark ? Colors.white : AppColors.duoTextDark),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l.voiceAiTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.duoTextDark,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (_active) ...[
                              if (_taskRemainingSeconds != null)
                                Builder(builder: (context) {
                                  final seconds = _taskRemainingSeconds!;
                                  if (seconds <= 0) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.duoRed
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppColors.duoRed),
                                      ),
                                      child: const Text(
                                        'Mashq vaqti tugadi (00:00)',
                                        style: TextStyle(
                                          color: AppColors.duoRed,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    );
                                  }
                                  final m = seconds ~/ 60;
                                  final s = seconds % 60;
                                  final timeStr =
                                      '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
                                  final isWarning = seconds <= 30;

                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 14,
                                        color: isWarning
                                            ? AppColors.duoRed
                                            : AppColors.duoOrange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Mashq vaqti: $timeStr',
                                        style: TextStyle(
                                          color: isWarning
                                              ? AppColors.duoRed
                                              : AppColors.duoOrange,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  );
                                })
                              else
                                ValueListenableBuilder<int>(
                                  valueListenable: _service.remainingSeconds,
                                  builder: (context, seconds, _) {
                                    final m = seconds ~/ 60;
                                    final s = seconds % 60;
                                    final timeStr =
                                        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
                                    return Text(
                                      'Limit: $timeStr',
                                      style: TextStyle(
                                        color: seconds <= 300
                                            ? AppColors.duoRed
                                            : AppColors.duoGreen,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ],
                        ),
                      ),

                      IconButton(
                        icon: Icon(Icons.tune_rounded,
                            color: isDark ? Colors.white70 : AppColors.duoTextLight),
                        onPressed: _active ? null : _showPersonalityDialog,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // Layer 0: Fixed main screen UI
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            _buildModeSelector(isDark),
                            const Spacer(),
                          // Markazdagi Yuz yoki 3D Businesswoman Personaj
                          ValueListenableBuilder<AiFaceState>(
                            valueListenable: _service.state,
                            builder: (context, faceState, _) {
                              final s = _active ? faceState : AiFaceState.idle;
                              return ValueListenableBuilder<AiFaceEmotion>(
                                valueListenable: _service.emotion,
                                builder: (context, emo, _) {
                                  return ValueListenableBuilder<double>(
                                    valueListenable: _service.mouthLevel,
                                    builder: (context, level, _) {
                                      return Column(
                                        children: [
                                          AiVoiceFace(
                                            state: s,
                                            emotion: emo,
                                            size: 200,
                                            level: s == AiFaceState.speaking ? level : null,
                                          ),
                                          const SizedBox(height: 24),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF1F2C33) : Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isDark ? Colors.white12 : Colors.black12,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
                                              ],
                                            ),
                                            child: Text(
                                              _statusText(l, s),
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white.withValues(alpha: 0.9)
                                                    : AppColors.duoTextDark.withValues(alpha: 0.9),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          // Xato xabari.
                          ValueListenableBuilder<String?>(
                            valueListenable: _service.error,
                            builder: (context, err, _) {
                              if (err == null || err.isEmpty) {
                                return const SizedBox(height: 20);
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  err,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.duoRed.withValues(alpha: 0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),

                          const Spacer(),

                          // Pastki boshqaruv.
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: _active ? _buildActiveControls() : _buildStartButton(),
                          ),
                        ],
                      ),
                    ),

                      // Layer 1: Floating top task dropdown panel (1-sloy, ustida turadi)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _buildTaskSection(isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _connect,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.duoBlue,
          boxShadow: [
            BoxShadow(
              color: AppColors.duoBlue.withValues(alpha: 0.5),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.mic_rounded, color: Colors.white, size: 38),
      ),
    );
  }

  Widget _buildActiveControls() {
    final isSpeaking = _service.state.value == AiFaceState.speaking;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Chap tomonda: Sessiyani tugatish tugmasi
        GestureDetector(
          onTap: _endSession,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(color: AppColors.duoRed, width: 2),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.duoRed,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 40),

        // Markazda: Ovozli boshqaruv tugmasi (AI gapirganda to'xtatish / Tinglayotganda mikrofon)
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            final glow = _pulseAnim.value;
            final baseColor = isSpeaking ? const Color(0xFFFF3B5C) : AppColors.duoGreen;
            final icon = isSpeaking ? Icons.stop_rounded : Icons.mic_rounded;

            return GestureDetector(
              onTap: () {
                if (isSpeaking) {
                  _service.interrupt();
                  setState(() {});
                }
              },
              child: SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring
                    Container(
                      width: 84 + 28 * glow,
                      height: 84 + 28 * glow,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: baseColor.withValues(alpha: 0.18 * (1 - glow * 0.6)),
                      ),
                    ),
                    // Middle ring
                    Container(
                      width: 84 + 12 * glow,
                      height: 84 + 12 * glow,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: baseColor.withValues(alpha: 0.22 * (1 - glow * 0.4)),
                      ),
                    ),
                    // Main button
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color.lerp(baseColor, isSpeaking ? const Color(0xFFFF6B6B) : const Color(0xFF78E020), glow)!,
                            baseColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: baseColor.withValues(alpha: 0.4 + 0.3 * glow),
                            blurRadius: 20 + 16 * glow,
                            spreadRadius: 2 + 4 * glow,
                          ),
                        ],
                      ),
                      child: Transform.rotate(
                        angle: isSpeaking ? math.pi * 0.1 * math.sin(glow * math.pi) : 0.0,
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 40),
        const SizedBox(width: 56), // Simmetriya uchun bo'sh joy
      ],
    );
  }

  Widget _buildModeSelector(bool isDark) {
    final isFromSprechen = widget.initialTaskInstruction != null ||
        widget.initialAufgabe != null ||
        widget.initialTaskTitle != null ||
        _activeAufgabe != null ||
        _activeTaskInstruction != null;

    if (_active || isFromSprechen) return const SizedBox.shrink();

    final modes = [
      {'mode': VoiceAiMode.telc, 'name': 'Telc / Goethe'},
      {'mode': VoiceAiMode.lugat, 'name': 'Lug\'at imtihoni'},
      {'mode': VoiceAiMode.magazin, 'name': 'Do\'konda'},
      {'mode': VoiceAiMode.politsiya, 'name': 'Chegara'},
      {'mode': VoiceAiMode.ijara, 'name': 'Uy ijara'},
      {'mode': VoiceAiMode.hospital, 'name': 'Kasalxona'},
      {'mode': VoiceAiMode.cafe, 'name': 'Qahvaxona'},
      {'mode': VoiceAiMode.customRoleplay, 'name': 'Erkin'},
    ];

    return Column(
      children: [
        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: modes.length,
            itemBuilder: (context, index) {
              final m = modes[index]['mode'] as VoiceAiMode;
              final name = modes[index]['name'] as String;
              final isSelected = _selectedMode == m;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    name,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : AppColors.duoTextDark),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.duoBlue,
                  backgroundColor: isDark ? const Color(0xFF203038) : AppColors.duoCardGray,
                  checkmarkColor: Colors.white,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMode = m;
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskSection(bool isDark) {
    if (_activeTaskTitle == null &&
        _activeAufgabe == null &&
        (_activeTaskInstruction == null || _activeTaskInstruction!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final aufgabe = _activeAufgabe;
    final title = aufgabe?.title ?? _activeTaskTitle ?? 'Sprechen Mashqi';
    final partner = aufgabe?.partner ?? '';
    final isPlanung = (_activeTeilTitle != null &&
            _activeTeilTitle!.toLowerCase().contains('planen')) ||
        title.toLowerCase().contains('planen');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2A32) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.duoOrange.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header bar (click to expand/collapse)
          InkWell(
            onTap: () {
              setState(() {
                _isTaskExpanded = !_isTaskExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.duoOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.assignment_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.duoOrange,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (partner.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.duoBlue,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Teilnehmer $partner',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isTaskExpanded
                              ? 'Yopish uchun bosing'
                              : 'Topshiriq matni va punktlarni ko\'rish (bosing)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white70
                                : AppColors.duoTextDark.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _isTaskExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.duoOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  // Clear button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeTaskTitle = null;
                        _activeTaskInstruction = null;
                        _activeAufgabe = null;
                        _activeTeilTitle = null;
                        _isTaskExpanded = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white38 : Colors.black38,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content panel overlay (floating 1-sloy content)
          if (_isTaskExpanded) ...[
            Divider(
              height: 1,
              color: isDark ? Colors.white12 : Colors.black12,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: _buildTaskContent(isDark, aufgabe, partner, isPlanung),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskContent(bool isDark, SprechenAufgabe? aufgabe, String partner, bool isPlanung) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role banner for Teil 2 (A vs B)
        if (partner.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.duoBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.duoBlue.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_alt_rounded,
                    color: AppColors.duoBlue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Sizning rolingiz: ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: 'Teilnehmer $partner\n',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.duoBlue),
                        ),
                        const TextSpan(
                          text: 'Ovozli AI roli: ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: 'Teilnehmer ${partner == 'A' ? 'B' : 'A'}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.duoPurple),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ] else if (isPlanung) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.duoPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.duoPurple.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.handshake_rounded,
                    color: AppColors.duoPurple, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gemeinsam etwas planen: AI hamkoringiz bilan birga reja tuzing va barcha punktlarni kelishing!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppColors.duoTextDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Author info & opinion (Teil 2)
        if (aufgabe != null &&
            aufgabe.meinung != null &&
            aufgabe.meinung!.isNotEmpty) ...[
          if (aufgabe.author != null && aufgabe.author!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.person_pin_rounded,
                    size: 16, color: AppColors.duoOrange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Fikr muallifi: ${aufgabe.author!}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.duoOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.duoOrange
                  .withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(10),
              border: const Border(
                left: BorderSide(color: AppColors.duoOrange, width: 3.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.format_quote_rounded,
                    size: 18, color: AppColors.duoOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    aufgabe.meinung!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppColors.duoTextDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Keywords / Stichpunkte
        if (aufgabe != null && aufgabe.keywords.isNotEmpty) ...[
          Text(
            'STICHPUNKTE (${aufgabe.keywords.length} TA PUNKT):',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.duoBlue,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Column(
            children: aufgabe.keywords.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final kw = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.duoBlue
                        .withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.duoBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.duoBlue,
                        child: Text(
                          '$idx',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          kw,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.duoTextDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Examples / Redemittel
        if (aufgabe != null && aufgabe.examples.isNotEmpty) ...[
          Text(
            'REDEMITTEL (FOYDALI IBORALAR):',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.duoGreen,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.duoGreen.withValues(alpha: isDark ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: aufgabe.examples.map((ex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 13, color: AppColors.duoGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ex,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.9)
                                : AppColors.duoTextDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        // Fallback string if task has no structured aufgabe
        if (aufgabe == null &&
            _activeTaskInstruction != null &&
            _activeTaskInstruction!.isNotEmpty) ...[
          Text(
            _activeTaskInstruction!,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
        ],
      ],
    );
  }
}
