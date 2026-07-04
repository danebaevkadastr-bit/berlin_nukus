// Ovozli AI (STT→LLM→TTS pipeline) ekrani.
//
// Foydalanuvchi tugmani bosib turib gapiradi → qo'yib yuborgach STT→LLM→TTS
// pipeline ishlaydi → bot Amazon Polly orqali javob beradi.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/locale_manager.dart';
import '../../services/gemini_live_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/ai_voice_face.dart';

class VoiceAiScreen extends StatefulWidget {
  const VoiceAiScreen({super.key});

  @override
  State<VoiceAiScreen> createState() => _VoiceAiScreenState();
}

class _VoiceAiScreenState extends State<VoiceAiScreen> {
  final GeminiLiveService _service = GeminiLiveService();
  bool _active = false;
  bool _holding = false;

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
    if (_holding) return "Botni to'xtatish";
    return l.voiceAiListening ?? 'Eshitilmoqda... (Gapiring)';
  }

  Future<void> _connect() async {
    setState(() => _active = true);
    await _service.connect(
      uiLangCode: LocaleManager.code,
      customPersonality: _customPersonality.isNotEmpty ? _customPersonality : null,
    );
  }

  Future<void> _endSession() async {
    await _service.disconnect();
    if (mounted) setState(() {
      _active = false;
      _holding = false;
    });
  }

  void _pressStart() {
    if (!_active) return;
    _service.interrupt();
    setState(() => _holding = true);
  }

  void _pressEnd() {
    if (!_holding) return;
    setState(() => _holding = false);
  }

  void _showPersonalityDialog() {
    _personalityCtrl.text = _customPersonality;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2B50),
        title: const Text('AI shaxsiyatini sozlash',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: _personalityCtrl,
          maxLines: 6,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Masalan: "Sen qat\'iy Herr Müller o\'qituvchisan, '
                'xatolarni keskin ko\'rsatasan..."',
            hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
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
            child: const Text('Bekor', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              _savePersonality(_personalityCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Saqlash',
                style: TextStyle(color: AppColors.duoBlue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1830),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF16244A), Color(0xFF0B1226)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Yuqori panel.
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        l.voiceAiTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, color: Colors.white70),
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
                                  color: Colors.white.withValues(alpha: 0.9),
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
                  if (err == null || err.isEmpty) return const SizedBox(height: 20);
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
      ),
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
    final micColor = _holding ? AppColors.duoGreen : AppColors.duoBlue;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Sessiyani tugatish.
        GestureDetector(
          onTap: _endSession,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.duoRed, width: 2),
            ),
            child: const Icon(Icons.close_rounded,
                color: AppColors.duoRed, size: 26),
          ),
        ),
        const SizedBox(width: 40),
        // Push-to-talk mikrofoni.
        Listener(
          onPointerDown: (_) => _pressStart(),
          onPointerUp: (_) => _pressEnd(),
          onPointerCancel: (_) => _pressEnd(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: _holding ? 96 : 84,
            height: _holding ? 96 : 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: micColor,
              boxShadow: [
                BoxShadow(
                  color: micColor.withValues(alpha: 0.5),
                  blurRadius: _holding ? 34 : 24,
                  spreadRadius: _holding ? 4 : 2,
                ),
              ],
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(width: 40),
        const SizedBox(width: 56), // balans
      ],
    );
  }
}
