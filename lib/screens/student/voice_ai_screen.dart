// Ovozli AI (STT→LLM→TTS pipeline) ekrani.
//
// Foydalanuvchi tugmani bosib turib gapiradi → qo'yib yuborgach STT→LLM→TTS
// pipeline ishlaydi → bot Amazon Polly orqali javob beradi.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/user_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/locale_manager.dart';
import '../../services/gemini_live_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/ai_voice_face.dart';

class VoiceAiScreen extends StatefulWidget {
  const VoiceAiScreen({super.key});

  @override
  State<VoiceAiScreen> createState() => _VoiceAiScreenState();
}

class _VoiceAiScreenState extends State<VoiceAiScreen> {
  final GeminiLiveService _service = GeminiLiveService();
  bool _active = false;

  // Foydalanuvchi kiritgan AI shaxsiyat sozlamalari (persistent).
  String _customPersonality = '';
  final TextEditingController _personalityCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPersonality();
  }

  @override
  void dispose() {
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
    return l.voiceAiListening ?? 'Eshitilmoqda... (Gapiring)';
  }

  Future<void> _connect() async {
    setState(() => _active = true);
    final userName =
        context.read<UserProvider>().name; // fullName dan birinchi so'z
    await _service.connect(
      uiLangCode: LocaleManager.code,
      customPersonality:
          _customPersonality.isNotEmpty ? _customPersonality : null,
      userName: userName.isNotEmpty ? userName : null,
    );
  }

  Future<void> _endSession() async {
    await _service.disconnect();
    if (mounted)
      setState(() {
        _active = false;
      });
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
                        child: Text(
                          l.voiceAiTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.duoTextDark,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
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
                const Spacer(),
                // Markazdagi yuz.
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
                                  size: 240,
                                  level: s == AiFaceState.speaking ? level : null,
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  _statusText(l, s),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : AppColors.duoTextDark.withValues(alpha: 0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
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
                  if (err == null || err.isEmpty)
                    return const SizedBox(height: 20);
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
    return GestureDetector(
      onTap: _endSession,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.duoRed,
          boxShadow: [
            BoxShadow(
              color: AppColors.duoRed.withValues(alpha: 0.5),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.stop_rounded, color: Colors.white, size: 40),
      ),
    );
  }
}
