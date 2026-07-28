import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/theme_manager.dart';
import '../../../widgets/gamified_card.dart';
import '../chat_screen.dart';
import '../voice_ai_screen.dart';
import '../../../services/gemini_live_prompt.dart';
import 'sprechen_data.dart';
import 'sprechen_recording_control.dart';
import 'sprechen_recording_models.dart';

/// Bitta Sprechen Teil'ining topshiriqlarini (Aufgaben) ko'rsatadi:
/// ko'rsatma, kalit so'zlar (kartochkalar) va misol iboralar.
/// Teil 2 (ko'p testli) — gorizontal scroll bilan test tanlanadi.
class SprechenTeilScreen extends StatefulWidget {
  final SprechenTeil teil;
  final String level;

  const SprechenTeilScreen({
    super.key,
    required this.teil,
    required this.level,
  });

  @override
  State<SprechenTeilScreen> createState() => _SprechenTeilScreenState();
}

class _SprechenTeilScreenState extends State<SprechenTeilScreen> {
  int _currentTest = 0;
  final _testScrollController = ScrollController();
  final SprechenRecordingCoordinator _recordingCoordinator =
      SprechenRecordingCoordinator();

  Color get _accent => ThemeManager.accent;
  Color get _accentShadow => ThemeManager.accentShadow;

  bool get _isMultiTest => widget.teil.tests.isNotEmpty;

  /// Joriy ko'rsatiladigan topshiriqlar (test tanlangan bo'lsa shu testniki).
  List<SprechenAufgabe> get _currentAufgaben =>
      _isMultiTest ? widget.teil.tests[_currentTest].aufgaben : widget.teil.aufgaben;

  @override
  void dispose() {
    _testScrollController.dispose();
    _recordingCoordinator.dispose();
    super.dispose();
  }

  void _goToTest(int index) {
    if (index < 0 || index >= widget.teil.tests.length) return;
    // Boshqa testga o'tganda faol yozishni to'xtatish uchun koordinatorni
    // tozalaymiz (RecordingControl dispose bo'lib, yozuvni o'chiradi).
    _recordingCoordinator.active.value = null;
    setState(() => _currentTest = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_testScrollController.hasClients) return;
      const itemWidth = 70.0;
      final offset = (index * itemWidth)
          .clamp(0.0, _testScrollController.position.maxScrollExtent);
      _testScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Teil ${widget.teil.teilNumber} – ${widget.level}',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Ko'p testli Teil — gorizontal test tanlovchi
          if (_isMultiTest) _buildTestPicker(isDark, l),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teil sarlavhasi va tavsifi
                  Text(
                    widget.teil.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.teil.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: isDark ? Colors.white70 : AppColors.duoTextLight,
                    ),
                  ),
                  const SizedBox(height: 22),

                  ..._currentAufgaben.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final aufgabe = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child:
                          _buildAufgabeCard(context, isDark, l, idx, aufgabe),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Test tanlovchi (gorizontal scroll) ──────────────────────────────────
  Widget _buildTestPicker(bool isDark, AppLocalizations l) {
    final tests = widget.teil.tests;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          GamifiedCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: _accent,
            shadowColor: _accentShadow,
            shadowDepth: 4,
            borderRadius: 20,
            child: Text(
              '${_currentTest + 1} / ${tests.length}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                controller: _testScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: tests.length,
                itemBuilder: (context, i) {
                  final selected = i == _currentTest;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _goToTest(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? _accent
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? _accentShadow
                                : (isDark
                                    ? Colors.white24
                                    : AppColors.duoCardGrayShadow),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '${l.sprechenTest} ${i + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: selected
                                ? Colors.white
                                : (isDark
                                    ? Colors.white70
                                    : AppColors.duoTextDark),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAufgabeCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l,
    int index,
    SprechenAufgabe aufgabe,
  ) {
    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;

    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : _accentShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topshiriq sarlavhasi
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: _accentShadow, offset: const Offset(0, 2)),
                  ],
                ),
                child: aufgabe.partner.isNotEmpty
                    ? Text(
                        aufgabe.partner,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.mic_rounded,
                        color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (aufgabe.partner.isNotEmpty)
                      Text(
                        '${l.sprechenCandidate} ${aufgabe.partner}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: _accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    Text(
                      aufgabe.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Ko'rsatma
          Text(
            aufgabe.instruction,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: textPrimary,
            ),
          ),

          // Meinung (fikr) kartasi — o'qib, fikr bildiriladi
          if (aufgabe.meinung != null && aufgabe.meinung!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: isDark ? 0.12 : 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border(
                  left: BorderSide(color: _accent, width: 4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded, size: 20, color: _accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aufgabe.meinung!,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                            color: textPrimary,
                          ),
                        ),
                        if (aufgabe.author != null &&
                            aufgabe.author!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '— ${aufgabe.author!}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _accent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Kalit so'zlar (kartochkalar)
          if (aufgabe.keywords.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l.sprechenKeywords.toUpperCase(),
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
              children: aufgabe.keywords.map((kw) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    kw,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Misol iboralar
          if (aufgabe.examples.isNotEmpty) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    size: 16, color: AppColors.duoGreen),
                const SizedBox(width: 6),
                Text(
                  l.sprechenExamples.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.duoGreen,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.duoGreen.withValues(alpha: isDark ? 0.1 : 0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: aufgabe.examples.map((ex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2, right: 8),
                          child: Icon(Icons.chat_bubble_outline_rounded,
                              size: 13, color: AppColors.duoGreen),
                        ),
                        Expanded(
                          child: Text(
                            ex,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: textPrimary,
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

          // Namuna javob (bosilganda ochiladi)
          if (aufgabe.sampleAnswer != null &&
              aufgabe.sampleAnswer!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SampleAnswerPanel(
              title: l.sprechenSampleAnswer,
              text: aufgabe.sampleAnswer!,
              accent: _accent,
              isDark: isDark,
            ),
          ],

          // Audio yozish + AI baholash kontroli
          // Faqat Teil 1 va Teil 2 uchun (Teil 3 — AI bilan mashq orqali)
          if (widget.teil.title != 'Gemeinsam etwas planen' &&
              !widget.teil.title.contains('planen') &&
              !widget.teil.title.contains('Lösung'))
            SprechenRecordingControl(
              key: ValueKey(
                  'rec_${widget.teil.teilNumber}_${_currentTest}_$index'),
              aufgabeKey: AufgabeKey(
                teilNumber: widget.teil.teilNumber,
                testIndex: _isMultiTest ? _currentTest : 0,
                aufgabeIndex: index,
              ),
              aufgabe: aufgabe,
              level: widget.level,
              coordinator: _recordingCoordinator,
            ),

          const SizedBox(height: 14),
          // Ovozli AI (Gemini Live) bilan jonli muloqot va mashq qilish
          GamifiedCard(
            color: AppColors.duoOrange,
            shadowColor: AppColors.duoOrangeShadow,
            shadowDepth: 4,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            onTap: () {
              final formattedTask = _formatAufgabeInstruction(widget.teil.title, aufgabe);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VoiceAiScreen(
                    initialTaskTitle: aufgabe.title,
                    initialTaskInstruction: formattedTask,
                    initialMode: VoiceAiMode.telc,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ovozli AI bilan jonli mashq 🎙️',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Shu mavzu va barcha punktlar bo\'yicha real vaqtda gaplashing',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 16,
                ),
              ],
            ),
          ),

          // Matnli "AI bilan mashq" tugmasi — faqat Teil 3 (Gemeinsam planen) uchun
          if (widget.teil.title.contains('planen') ||
              widget.teil.title.contains('Lösung')) ...[
            const SizedBox(height: 10),
            GamifiedCard(
              color: AppColors.duoPurple,
              shadowColor: AppColors.duoPurple.withValues(alpha: 0.4),
              shadowDepth: 4,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      title: aufgabe.title,
                      sourceType: 'planung',
                      isPlanungPartner: true,
                      planungSituation: aufgabe.instruction,
                      planungKeywords: aufgabe.keywords,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.sprechenPlanWithAi,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.sprechenPlanWithAiHint,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatAufgabeInstruction(String teilTitle, SprechenAufgabe aufgabe) {
    final buf = StringBuffer();
    buf.writeln('Teil: $teilTitle');
    buf.writeln('Mavzu sarlavhasi: ${aufgabe.title}');
    if (aufgabe.instruction.isNotEmpty) {
      buf.writeln('Ko\'rsatma: ${aufgabe.instruction}');
    }
    if (aufgabe.partner.isNotEmpty) {
      buf.writeln('Nomzod (Teilnehmer): ${aufgabe.partner}');
    }
    if (aufgabe.meinung != null && aufgabe.meinung!.isNotEmpty) {
      buf.writeln('Fikr kartasi (Meinung): "${aufgabe.meinung}" ${aufgabe.author != null ? '(${aufgabe.author})' : ''}');
    }
    if (aufgabe.keywords.isNotEmpty) {
      buf.writeln('Stichpunkte (Punktlar / Kalit so\'zlar):');
      for (var k in aufgabe.keywords) {
        buf.writeln('- $k');
      }
    }
    if (aufgabe.examples.isNotEmpty) {
      buf.writeln('Redemittel (Misol iboralar):');
      for (var e in aufgabe.examples.take(4)) {
        buf.writeln('- $e');
      }
    }
    return buf.toString();
  }
}

/// Namuna javob paneli — sarlavhaga bosilganda ochilib/yopiladi.
class _SampleAnswerPanel extends StatefulWidget {
  final String title;
  final String text;
  final Color accent;
  final bool isDark;

  const _SampleAnswerPanel({
    required this.title,
    required this.text,
    required this.accent,
    required this.isDark,
  });

  @override
  State<_SampleAnswerPanel> createState() => _SampleAnswerPanelState();
}

class _SampleAnswerPanelState extends State<_SampleAnswerPanel> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        widget.isDark ? Colors.white : AppColors.duoTextDark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.accent.withValues(alpha: widget.isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.accent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sarlavha (bosiladigan)
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.menu_book_rounded,
                      size: 18, color: widget.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: widget.accent,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: widget.accent),
                  ),
                ],
              ),
            ),
          ),
          // Matn (ochilganda)
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                  color: textPrimary,
                ),
              ),
            ),
            crossFadeState:
                _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}
