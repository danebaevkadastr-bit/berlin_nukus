// B1 Mock Test — overview (burger) drawer.
//
// An overlay panel that lists every Section and its Teile in the official TELC
// B1 order and lets the student jump straight to any Teil (Requirements 2.2,
// 2.3, 9.4). Sections are always labelled in German via [mockSectionGermanName]
// regardless of the interface locale (Requirements 2.6, 11.2), while the
// surrounding app-authored chrome (the drawer title) is localized through
// [AppLocalizations] (Requirement 11.1).
//
// The currently active Teil — `controller.currentTeilIndex` — is highlighted in
// the accent color (Requirement 2.4). Tapping a Teil calls [onSelectTeil] with
// that Teil's global index and then [onClose]; the runner wires those to
// `controller.goToTeil(index)` plus the close animation's `reverse()`
// (Requirement 2.3). Navigation only moves the cursor, so previously entered
// answers are preserved (Requirement 2.5).
//
// Both the panel slide and the dimming scrim are driven by the externally
// supplied [animation] (`0` = closed, `1` = fully open), which the runner keeps
// in sync with the burger → X icon morph. Surfaces use [GamifiedCard],
// [AppColors] and [ThemeManager] dark-mode colors to match the app design
// language (Requirements 1.1, 1.2, 1.3).

import 'package:flutter/material.dart';

import 'package:core/l10n/app_localizations.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/gamified_card.dart';
import '../mock_test_controller.dart';
import '../model/mock_test_labels.dart';
import '../model/mock_test_structure.dart';

/// Slide-in overview drawer listing all Sections and their Teile.
///
/// Rendered as an overlay on top of the runner; the parent stacks it above the
/// body content and drives [animation] to open/close it.
class MockOverviewDrawer extends StatelessWidget {
  /// The attempt controller — read for the Teil list and the active Teil index.
  final MockTestController controller;

  /// Open/close progress: `0` = closed (off-screen, scrim clear), `1` = fully
  /// open (on-screen, scrim dim). Drives both the slide and the scrim.
  final Animation<double> animation;

  /// Called with the global Teil index when a Teil row is tapped. The runner
  /// wires this to `controller.goToTeil(index)`.
  final void Function(int teilIndex) onSelectTeil;

  /// Called to close the drawer (scrim tap, close button, or after a Teil is
  /// selected). The runner wires this to the close animation's `reverse()`.
  final VoidCallback onClose;

  const MockOverviewDrawer({
    super.key,
    required this.controller,
    required this.animation,
    required this.onSelectTeil,
    required this.onClose,
  });

  /// Maximum dim of the scrim at fully-open.
  static const double _scrimMaxOpacity = 0.5;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final panelWidth = (media.size.width * 0.85).clamp(0.0, 340.0).toDouble();

    // Rebuild on both the open/close animation and controller changes so the
    // active-Teil highlight stays current.
    return AnimatedBuilder(
      animation: Listenable.merge([animation, controller]),
      builder: (context, _) {
        final t = animation.value.clamp(0.0, 1.0);

        return IgnorePointer(
          // When fully closed the overlay must not intercept taps on the runner.
          ignoring: t == 0,
          child: Stack(
            children: [
              // ── Scrim (tap to close) ────────────────────────────────────
              Positioned.fill(
                child: Opacity(
                  opacity: t * _scrimMaxOpacity,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClose,
                    child: const ColoredBox(color: Colors.black),
                  ),
                ),
              ),

              // ── Sliding panel ───────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: FractionalTranslation(
                  // -1 (fully off-screen left) → 0 (fully in place).
                  translation: Offset(t - 1.0, 0),
                  child: SizedBox(
                    width: panelWidth,
                    child: _buildPanel(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPanel(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final panelBg = ThemeManager.scaffoldBg(context);
    final textColor = ThemeManager.textColor(context);

    return Material(
      color: panelBg,
      elevation: 8,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header: title + close (X) ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.mockOverviewTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    splashRadius: 22,
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: (isDark ? Colors.white : AppColors.duoTextDark)
                  .withValues(alpha: 0.12),
            ),

            // ── Section / Teil list ───────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: _buildSectionTiles(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the section headers + Teil tiles in official Section order.
  ///
  /// Each attempt Teil keeps its global index (its position in
  /// `attempt.teile`), so out-of-order assembled Teile still group correctly
  /// under their German Section headers and jump to the right cursor position.
  List<Widget> _buildSectionTiles(BuildContext context) {
    final textColor = ThemeManager.textColor(context);
    final subTextColor = ThemeManager.subTextColor(context);
    final teile = controller.attempt.teile;
    final tiles = <Widget>[];

    for (final section in MockTestStructure.sectionOrder) {
      // Collect this Section's Teile, preserving each one's global index.
      final entries = <MapEntry<int, int>>[]; // globalIndex → teilNumber
      for (var i = 0; i < teile.length; i++) {
        if (teile[i].section == section) {
          entries.add(MapEntry(i, teile[i].teilNumber));
        }
      }
      if (entries.isEmpty) continue;

      // German Section header (never localized — Requirements 2.6, 11.2).
      tiles.add(
        Padding(
          padding: EdgeInsets.only(top: tiles.isEmpty ? 0 : 20, bottom: 10),
          child: Text(
            mockSectionGermanName(section),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: subTextColor,
            ),
          ),
        ),
      );

      for (final entry in entries) {
        tiles.add(_buildTeilTile(context, entry.key, entry.value, textColor));
      }
    }

    return tiles;
  }

  Widget _buildTeilTile(
    BuildContext context,
    int globalIndex,
    int teilNumber,
    Color textColor,
  ) {
    final isCurrent = globalIndex == controller.currentTeilIndex;
    final accent = ThemeManager.accent;
    final accentShadow = ThemeManager.accentShadow;
    final cardColor = ThemeManager.cardColor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GamifiedCard(
        // Active Teil is highlighted in the accent color (Requirement 2.4).
        color: isCurrent ? accent : cardColor,
        shadowColor: isCurrent ? accentShadow : AppColors.duoCardGrayShadow,
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: () {
          // Jump to the Teil, then close (runner wires goToTeil + reverse).
          onSelectTeil(globalIndex);
          onClose();
        },
        child: Row(
          children: [
            Icon(
              isCurrent
                  ? Icons.play_circle_fill_rounded
                  : Icons.circle_outlined,
              size: 22,
              color: isCurrent ? Colors.white : accent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                // German exam label — never localized (Requirement 11.2).
                'Teil $teilNumber',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isCurrent ? Colors.white : textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
