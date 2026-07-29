// Ovozli AI (STT→LLM→TTS pipeline) ekrani.
//
// Foydalanuvchi tugmani bosib turib gapiradi → qo'yib yuborgach STT→LLM→TTS
// pipeline ishlaydi → bot Amazon Polly orqali javob beradi.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../core/providers/user_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/locale_manager.dart';
import '../../services/gemini_live_service.dart';
import '../../services/gemini_live_prompt.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/ai_voice_face.dart';

class VoiceAiScreen extends StatefulWidget {
  final String? initialTaskInstruction;
  final String? initialTaskTitle;
  final VoiceAiMode? initialMode;

  const VoiceAiScreen({
    super.key,
    this.initialTaskInstruction,
    this.initialTaskTitle,
    this.initialMode,
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

  Future<void> _connect() async {
    setState(() => _active = true);
    final userName =
        context.read<UserProvider>().name; // fullName dan birinchi so'z
    await _service.connect(
      uiLangCode: LocaleManager.code,
      mode: _selectedMode,
      customPersonality:
          _customPersonality.isNotEmpty ? _customPersonality : null,
      userName: userName.isNotEmpty ? userName : null,
      dynamicTaskInstruction: _activeTaskInstruction,
    );
  }

  Future<void> _endSession() async {
    await _service.disconnect();
    if (mounted) {
      setState(() {
        _active = false;
      });
    }
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
                            if (_active)
                              ValueListenableBuilder<int>(
                                valueListenable: _service.remainingSeconds,
                                builder: (context, seconds, _) {
                                  final m = seconds ~/ 60;
                                  final s = seconds % 60;
                                  final timeStr = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
                                  return Text(
                                    timeStr,
                                    style: TextStyle(
                                      color: seconds <= 300 ? AppColors.duoRed : AppColors.duoGreen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
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
    if (_active) return const SizedBox.shrink();

    final modes = [
      {'mode': VoiceAiMode.telc, 'name': 'Telc / Goethe'},
      {'mode': VoiceAiMode.magazin, 'name': 'Do\'konda'},
      {'mode': VoiceAiMode.politsiya, 'name': 'Chegara'},
      {'mode': VoiceAiMode.ijara, 'name': 'Uy ijara'},
      {'mode': VoiceAiMode.hospital, 'name': 'Kasalxona'},
      {'mode': VoiceAiMode.cafe, 'name': 'Qahvaxona'},
      {'mode': VoiceAiMode.customRoleplay, 'name': 'Erkin'},
    ];

    return Column(
      children: [
        // Active task banner (if selected)
        if (_activeTaskTitle != null && _activeTaskTitle!.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.duoOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.duoOrange, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: AppColors.duoOrange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mavzu: $_activeTaskTitle',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.duoOrange,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTaskTitle = null;
                      _activeTaskInstruction = null;
                    });
                  },
                  child: const Icon(Icons.close_rounded, color: AppColors.duoOrange, size: 18),
                ),
              ],
            ),
          ),

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
}
