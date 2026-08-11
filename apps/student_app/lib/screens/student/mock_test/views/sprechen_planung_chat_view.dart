// B1 Mock Test — Sprechen Teil 3 ("Gemeinsam etwas planen") chat interfeysi.
//
// Teil 3 real imtihonda ikki nomzod birgalikda reja quradi. Audio yozib
// yuborish o'rniga bu yerda AI Teilnehmer B (hamkor) bo'lib chat orqali
// gaplashadi. Foydalanuvchi barcha nuqtalarni muhokama qilib bo'lgach
// "Yakunlash va baholash" tugmasini bosadi — shunda AI butun suhbat tarixini
// ko'rib JSON baho qo'yadi va u [MockTestController.recordSprechenEvaluation]
// orqali saqlanadi.
//
// Imtihon rejimi bo'lgani uchun bu yerda hint (yordamchi gaplar) ham,
// xato tuzatish (correction) ham YO'Q — faqat tabiiy suhbat.
//
// App matni [AppLocalizations] orqali lokalizatsiya qilinadi; nemischa imtihon
// mazmuni (situation, keywords, AI javoblari) nemis tilida qoladi.

import 'package:flutter/material.dart';

import 'package:core/l10n/app_localizations.dart';
import 'package:core/services/ai_service.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/gamified_card.dart';
import 'package:core/widgets/typing_dots.dart';
import '../../sprechen/sprechen_recording_models.dart';
import '../mock_test_controller.dart';
import '../model/mock_test_attempt.dart';

/// Teil 3 chat interfeysi: AI hamkor bilan reja qurish + oxirida baholash.
class SprechenPlanungChatView extends StatefulWidget {
  final MockTestController controller;
  final SelectedSprechenTest test;

  const SprechenPlanungChatView({
    super.key,
    required this.controller,
    required this.test,
  });

  @override
  State<SprechenPlanungChatView> createState() =>
      _SprechenPlanungChatViewState();
}

/// Bitta chat xabari (vaqtinchalik — hech qayerda saqlanmaydi).
class _Msg {
  final String role; // 'user' | 'assistant'
  final String text;
  const _Msg(this.role, this.text);
}

class _SprechenPlanungChatViewState extends State<SprechenPlanungChatView> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_Msg> _messages = [];

  bool _aiThinking = false;
  bool _evaluating = false;
  bool _finished = false;
  bool _evalError = false;

  /// Situation matni (AI hamkor va baholash uchun).
  String get _situation {
    final a = widget.test.aufgaben.isNotEmpty ? widget.test.aufgaben.first : null;
    final thema = widget.test.thema?.trim();
    final instruction = a?.instruction.trim() ?? '';
    if (thema != null && thema.isNotEmpty && instruction.isNotEmpty) {
      return '$thema — $instruction';
    }
    return instruction.isNotEmpty ? instruction : (thema ?? '');
  }

  /// Muhokama qilinadigan nuqtalar (barcha aufgaben keywordlari).
  List<String> get _keywords {
    final all = <String>[];
    for (final a in widget.test.aufgaben) {
      all.addAll(a.keywords);
    }
    return all;
  }

  @override
  void initState() {
    super.initState();
    // AI hamkor suhbatni boshlaydi (Teilnehmer B).
    _messages.add(_Msg(
      'assistant',
      'Also, wir sollen gemeinsam etwas planen: "${_situation}". '
          'Hast du schon eine Idee, wie wir anfangen könnten?',
    ));
    // Test yakunlanганда (time-up yoki Finish) suhbatni avtomatik baholash
    // uchun o'zimizni controllerга ro'yxatdan o'tkazamiz.
    widget.controller.sprechenFinalizer = _finalize;
  }

  @override
  void dispose() {
    // Faqat o'zimiznikini olib tashlaymiz (boshqa view yozgan bo'lishi mumkin).
    if (widget.controller.sprechenFinalizer == _finalize) {
      widget.controller.sprechenFinalizer = null;
    }
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Test yakunlanganда chaqiriladi. Agar suhbat hali baholanmagan bo'lsa va
  /// o'quvchi kamida bitta xabar yozgan bo'lsa — avtomatik baholaydi.
  Future<void> _finalize() async {
    if (_finished || _evaluating) return;
    if (!_messages.any((m) => m.role == 'user')) return;
    await _evaluate();
  }

  /// AI hamkor uchun system prompt (baholashsiz — faqat tabiiy hamkor).
  String get _partnerPrompt {
    final keywordsList = _keywords.isNotEmpty
        ? _keywords.map((k) => '- $k').join('\n')
        : '- (nuqtalar berilmagan)';
    return '''
Sen TELC B1 Sprechen Teil 3 imtihonida Teilnehmer B (hamkor) sisan.
Foydalanuvchi = Teilnehmer A. Siz birgalikda reja qurasiz.

TOPSHIRIQ (Situation):
"${_situation}"

MUHOKAMA QILINISHI KERAK BO'LGAN NUQTALAR:
$keywordsList

QOIDALAR (qat'iy):
- Hech qanday emoji, smaylik ishlatma.
- Sen o'qituvchi EMASSAN, imtihondagi hamkorsan (Teilnehmer B).
- Har javobda: o'z taklifingni ayt YOKI hamkorning taklifiga munosabat bildir, keyin keyingi nuqtaga o't.
- Javob qisqa bo'lsin: 2-4 gap. Real imtihondagidek tabiiy gapir.
- Faqat nemis tilida yoz (B1 daraja — sodda, tushunarli).
- Ba'zan rozi bo'l, ba'zan boshqa taklif ber.
- Hali muhokama qilinmagan nuqtalarga yo'nalt.
- Suhbatni bir o'zing yakunlama — foydalanuvchi qatnashishi kerak.
- XATOLARNI TUZATMA, baho BERMA — bu imtihon, dars emas. Baholashni tizim keyin alohida qiladi.
- Agar foydalanuvchi mavzudan chiqsa, uni rejaga qaytaring.''';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _aiThinking || _finished || _evaluating) return;

    setState(() {
      _messages.add(_Msg('user', text));
      _input.clear();
      _aiThinking = true;
    });
    _scrollToBottom();

    try {
      final history = _messages
          .map((m) => {'role': m.role, 'text': m.text})
          .toList();
      // Oxirgi user xabarini message sifatida yuboramiz, tarixdan chiqaramiz.
      final last = history.removeLast();
      final reply = await AIService.sendMessage(
        message: last['text'] as String,
        history: history,
        context: _partnerPrompt,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg('assistant', reply.trim()));
        _aiThinking = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _aiThinking = false);
    }
  }

  Future<void> _confirmAndFinish() async {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final accent = ThemeManager.accent;
    final bgColor = isDark ? const Color(0xFF1E2A32) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.duoTextDark;
    final secondaryColor = isDark ? Colors.white70 : AppColors.duoTextLight;
    final borderColor = isDark ? Colors.white12 : AppColors.duoCardGrayShadow;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: borderColor, width: 2),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        icon: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.done_all_rounded, color: accent, size: 34),
        ),
        title: Text(
          l.mockPlanungConfirmTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        content: Text(
          l.mockPlanungConfirmBody,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: secondaryColor,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogButton(
                  label: l.mockPlanungFinish,
                  color: accent,
                  shadowColor: ThemeManager.accentShadow,
                  textColor: Colors.white,
                  onTap: () => Navigator.pop(ctx, true),
                ),
                const SizedBox(height: 12),
                _dialogButton(
                  label: l.cancel,
                  color: isDark
                      ? const Color(0xFF2A3942)
                      : AppColors.duoCardGray,
                  shadowColor:
                      isDark ? Colors.black38 : AppColors.duoCardGrayShadow,
                  textColor: textColor,
                  onTap: () => Navigator.pop(ctx, false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _evaluate();
    }
  }

  /// Ilova uslubidagi to'liq kenglikdagi tugma (yakunlash dialogi uchun).
  Widget _dialogButton({
    required String label,
    required Color color,
    required Color shadowColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(bottom: BorderSide(color: shadowColor, width: 3)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _evaluate() async {
    if (_evaluating) return;
    setState(() {
      _evaluating = true;
      _evalError = false;
    });

    try {
      final json = await AIService.evaluateSprechenPlanung(
        situation: _situation,
        keywords: _keywords,
        history: _messages.map((m) => {'role': m.role, 'text': m.text}).toList(),
      );
      final eval = AudioEvaluation.fromJson(json);
      if (!eval.hasContent || eval.score.isEmpty) {
        throw Exception('empty evaluation');
      }
      widget.controller.recordSprechenEvaluation(3, eval);
      if (!mounted) return;
      setState(() {
        _evaluating = false;
        _finished = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _evaluating = false;
        _evalError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final accent = ThemeManager.accent;
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App-authored ko'rsatma (lokalizatsiya).
        Text(
          l.mockPlanungInstruction,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.5,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 14),

        // Situation banner (nemischa mazmun).
        _SituationBanner(situation: _situation, accent: accent, isDark: isDark),

        // Muhokama qilinadigan nuqtalar (nemischa).
        if (_keywords.isNotEmpty) ...[
          const SizedBox(height: 14),
          _KeywordsBlock(
            keywords: _keywords,
            label: l.sprechenKeywords,
            accent: accent,
            isDark: isDark,
            textSecondary: textSecondary,
          ),
        ],

        const SizedBox(height: 18),

        // Chat oynasi (belgilangan balandlik — sahifa aylantiriladigan bo'lgani uchun).
        GamifiedCard(
          color: isDark
              ? AppColors.duoCardGray.withValues(alpha: 0.1)
              : Colors.white,
          shadowColor: isDark ? Colors.black26 : ThemeManager.accentShadow,
          shadowDepth: 5,
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            height: 420,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _messages.length + (_aiThinking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _messages.length) {
                        return _TypingBubble(accent: accent, isDark: isDark);
                      }
                      final m = _messages[index];
                      return _Bubble(
                        text: m.text,
                        isUser: m.role == 'user',
                        accent: accent,
                        isDark: isDark,
                        partnerLabel: l.mockPlanungPartnerLabel,
                      );
                    },
                  ),
                ),
                if (!_finished) _buildInputBar(l, accent, isDark, textPrimary),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Yakunlash / holat paneli.
        _buildFooter(l, accent, isDark, textPrimary),
      ],
    );
  }

  Widget _buildInputBar(
      AppLocalizations l, Color accent, bool isDark, Color textPrimary) {
    final canType = !_aiThinking && !_evaluating;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              enabled: canType,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                hintText: l.mockPlanungInputHint,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Material(
            color: canType ? accent : accent.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: canType ? _send : null,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
      AppLocalizations l, Color accent, bool isDark, Color textPrimary) {
    if (_finished) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.duoGreen.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.duoGreen.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.duoGreen, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.mockPlanungDone,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  color: textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_evaluating) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                l.mockPlanungEvaluating,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_evalError) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.red, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.mockPlanungError,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _confirmAndFinish,
            icon: const Icon(Icons.done_all_rounded, color: Colors.white),
            label: Text(
              l.mockPlanungFinish,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Situation banner (nemischa mazmun).
class _SituationBanner extends StatelessWidget {
  final String situation;
  final Color accent;
  final bool isDark;

  const _SituationBanner({
    required this.situation,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.groups_2_rounded, size: 20, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              situation,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                height: 1.4,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Muhokama qilinadigan nuqtalar (nemischa) — lokalizatsiya qilingan sarlavha.
class _KeywordsBlock extends StatelessWidget {
  final List<String> keywords;
  final String label;
  final Color accent;
  final bool isDark;
  final Color textSecondary;

  const _KeywordsBlock({
    required this.keywords,
    required this.label,
    required this.accent,
    required this.isDark,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keywords.map((kw) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
              ),
              child: Text(
                kw,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Chat pufakchasi (foydalanuvchi yoki AI hamkor).
class _Bubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final Color accent;
  final bool isDark;
  final String partnerLabel;

  const _Bubble({
    required this.text,
    required this.isUser,
    required this.accent,
    required this.isDark,
    required this.partnerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser
        ? accent
        : (isDark ? Colors.white12 : accent.withValues(alpha: 0.08));
    final txtColor = isUser
        ? Colors.white
        : (isDark ? Colors.white : AppColors.duoTextDark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 3),
              child: Text(
                partnerLabel,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: accent,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: txtColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// AI javob yozayotganini ko'rsatuvchi pufakcha (animatsiyalangan nuqtalar).
class _TypingBubble extends StatelessWidget {
  final Color accent;
  final bool isDark;

  const _TypingBubble({required this.accent, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white12 : accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TypingDots(colors: [accent, accent, accent]),
          ),
        ],
      ),
    );
  }
}
