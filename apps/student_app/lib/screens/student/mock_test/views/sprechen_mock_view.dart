// B1 Mock Test — Mündlicher Ausdruck (Sprechen) section view.
//
// Renders the [SelectedSprechenTest] chosen for one Sprechen Teil (its optional
// theme plus the ordered Aufgaben) and embeds the existing
// [SprechenRecordingControl] for each Aufgabe so the student can record and
// submit a spoken answer. When the underlying [SprechenEvaluationService.evaluate]
// flow returns an [AudioEvaluation], it is stored on the [MockTestController]
// via `recordSprechenEvaluation`. If recording fails or the microphone is
// denied, the control surfaces a localized error itself and no evaluation is
// recorded — leaving the controller's evaluation null so the scorer flags the
// Mündlicher Ausdruck Section as unavailable while every other Section is still
// scored.
//
// App-authored interface text is localized through [AppLocalizations]; the
// German exam content (theme, instructions, opinions, example phrases) stays in
// German regardless of the active locale (Requirement 11.2).

import 'package:flutter/material.dart';

import 'package:core/l10n/app_localizations.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/gamified_card.dart';
import '../../sprechen/sprechen_data.dart';
import '../../sprechen/sprechen_recording_control.dart';
import '../../sprechen/sprechen_recording_models.dart';
import '../mock_test_controller.dart';
import '../model/mock_test_attempt.dart';
import 'sprechen_planung_chat_view.dart';

/// The interactive Sprechen view for a single mock-test Teil. Takes the
/// [MockTestController] and the index of the Teil to present.
class SprechenMockView extends StatefulWidget {
  final MockTestController controller;
  final int teilIndex;

  const SprechenMockView({
    super.key,
    required this.controller,
    required this.teilIndex,
  });

  @override
  State<SprechenMockView> createState() => _SprechenMockViewState();
}

class _SprechenMockViewState extends State<SprechenMockView> {
  /// Coordinates the per-Aufgabe recording controls so only one records at a
  /// time within this Teil.
  final SprechenRecordingCoordinator _coordinator =
      SprechenRecordingCoordinator();

  MockTeil get _teil => widget.controller.attempt.teile[widget.teilIndex];

  /// Teil 2 uchun ko'rsatiladigan yagona Aufgabe (Meinung) indeksi. Test
  /// mazmunidan (thema yoki birinchi sarlavha) barqaror hosil qilinadi —
  /// tasodifiy emas, shuning uchun Teilга qaytib kelinganda bir xil qoladi.
  int _selectedAufgabeIndex(SelectedSprechenTest test) {
    if (test.aufgaben.length <= 1) return 0;
    final key = (test.thema ?? test.aufgaben.first.title);
    return key.hashCode.abs() % test.aufgaben.length;
  }

  @override
  void dispose() {
    _coordinator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final test = _teil.test;

    // Defensive: this view only renders a Sprechen Teil. Any other selected
    // test type indicates a wiring error upstream.
    if (test is! SelectedSprechenTest) {
      return const SizedBox.shrink();
    }

    // Teil 3 "Gemeinsam etwas planen" ikki kishilik topshiriq — audio yozish
    // o'rniga AI hamkor (Teilnehmer B) bilan chat orqali rejalashtiriladi va
    // suhbat oxirida AI butun tarixni ko'rib baho qo'yadi.
    if (_teil.teilNumber == 3) {
      return SprechenPlanungChatView(
        key: ValueKey('mock_planung_${widget.teilIndex}'),
        controller: widget.controller,
        test: test,
      );
    }

    final textPrimary = isDark ? Colors.white : AppColors.duoTextDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.duoTextLight;

    // Teil 2 (Über ein Thema sprechen): real imtihonda har nomzod FAQAT bitta
    // fikr (Meinung) kartasi bo'yicha gapiradi. Shuning uchun ikki fikrdan
    // (A/B) faqat bittasini ko'rsatamiz. Tanlov test mazmuniga bog'liq
    // (barqaror) — Teilга qaytib kelinganda o'zgarmaydi.
    final aufgaben = (_teil.teilNumber == 2 && test.aufgaben.length > 1)
        ? [test.aufgaben[_selectedAufgabeIndex(test)]]
        : test.aufgaben;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App-authored instruction (localized).
        Text(
          l.mockSprechenInstruction,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.5,
            color: textSecondary,
          ),
        ),

        // Theme (German exam content) — shown when the selected test has one.
        if (test.thema != null && test.thema!.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _ThemaBanner(thema: test.thema!.trim(), label: l.mockSprechenThemaLabel),
        ],

        const SizedBox(height: 20),

        // Aufgabe kartalari — imtihon mazmuni (yozuvsiz). Teil 2 da ikkala
        // nomzod (A/B) fikri ko'rsatiladi, lekin o'quvchi butun Teil uchun
        // faqat BITTA marta yozadi. (Aks holda ikkinchi yozuv birinchisini
        // bir xil Teil slotida o'chirib yuborardi.)
        ...aufgaben.map((aufgabe) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _AufgabeCard(
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                aufgabe: aufgabe,
              ),
            )),

        // Butun Teil uchun bitta audio yozish + AI baholash kontroli.
        SprechenRecordingControl(
          key: ValueKey('mock_sprechen_${widget.teilIndex}'),
          aufgabeKey: AufgabeKey(
            teilNumber: _teil.teilNumber,
            testIndex: 0,
            aufgabeIndex: 0,
          ),
          aufgabe: aufgaben.first,
          level: 'B1',
          coordinator: _coordinator,
          // Imtihon rejimi: baho yozuv davomida ko'rsatilmaydi. Yuborilganda
          // audio saqlanadi (kutish yo'q), baholash test yakunida bajariladi.
          hideFeedback: true,
          onAudioSubmit: (bytes, mimeType) async {
            widget.controller.recordSprechenAudio(
              _teil.teilNumber,
              PendingSprechenAudio(
                bytes: bytes,
                mimeType: mimeType,
                aufgabe: aufgaben.first,
              ),
            );
          },
        ),
      ],
    );
  }
}

/// German-content theme banner for a multi-test Sprechen Teil.
class _ThemaBanner extends StatelessWidget {
  final String thema;
  final String label;

  const _ThemaBanner({required this.thema, required this.label});

  @override
  Widget build(BuildContext context) {
    final accent = ThemeManager.accent;
    final isDark = ThemeManager.isDark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.topic_rounded, size: 18, color: accent),
          const SizedBox(width: 10),
          // Label is app-authored (localized); the theme text is German content.
          Text(
            '${label.toUpperCase()}: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: accent,
              letterSpacing: 0.5,
            ),
          ),
          Expanded(
            child: Text(
              thema,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One Aufgabe card: German exam content (title, instruction, opinion,
/// keywords, example phrases, sample answer). In the mock test a single
/// recording control is shown once per Teil (below all cards), not per Aufgabe.
class _AufgabeCard extends StatelessWidget {
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final SprechenAufgabe aufgabe;

  const _AufgabeCard({
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.aufgabe,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = ThemeManager.accent;
    final accentShadow = ThemeManager.accentShadow;

    return GamifiedCard(
      color:
          isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : accentShadow,
      shadowDepth: 5,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row (with candidate badge when present).
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: accentShadow, offset: const Offset(0, 2)),
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
                          color: accent,
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

          // Instruction (German content).
          Text(
            aufgabe.instruction,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: textPrimary,
            ),
          ),

          // Opinion card (German content) — read aloud and react.
          if (aufgabe.meinung != null && aufgabe.meinung!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.12 : 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border(left: BorderSide(color: accent, width: 4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded, size: 20, color: accent),
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
                                color: accent,
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

          // Keywords (German content) with a localized section label.
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
                    color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
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

          // Example phrases (German content) with a localized section label.
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
                color:
                    AppColors.duoGreen.withValues(alpha: isDark ? 0.1 : 0.07),
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

          // Sample answer (German content) — expandable.
          if (aufgabe.sampleAnswer != null &&
              aufgabe.sampleAnswer!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SampleAnswerPanel(
              title: l.sprechenSampleAnswer,
              text: aufgabe.sampleAnswer!,
              accent: accent,
              isDark: isDark,
            ),
          ],

        ],
      ),
    );
  }
}

/// Expandable sample-answer panel (German content body, localized title).
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
    final textPrimary = widget.isDark ? Colors.white : AppColors.duoTextDark;

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
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.menu_book_rounded, size: 18, color: widget.accent),
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
