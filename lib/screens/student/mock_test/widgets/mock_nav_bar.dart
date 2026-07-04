// B1 Mock Test — redesigned bottom navigation bar.
//
// Renders the Previous / Next / Finish controls at the bottom of the runner.
// Its behavior differs from the previous runner's nav bar: on the final Teil
// the Next control stays visible but DISABLED (it never morphs into "Finish"),
// and a separate, clearly distinct Finish control appears instead. The Finish
// control is shown ONLY on the final Teil, so an attempt can never be finished
// early (Requirement 8.6).
//
//  ┌─────────────┬──────────────┬──────────────┐
//  │ Holat       │ Previous     │ Next  Finish │
//  ├─────────────┼──────────────┼──────────────┤
//  │ First Teil  │ hidden       │ active        — │  (R8.1, R8.6)
//  │ Middle Teil │ active       │ active        — │  (R8.2, R8.6)
//  │ Final Teil  │ active       │ DISABLED  active│  (R8.3, R8.4)
//  └─────────────┴──────────────┴──────────────┘
//
// App-authored labels come from [AppLocalizations]; nothing here is German exam
// content. Styling follows the Design_System (`AppColors`, the active accent and
// dark mode) per Requirements 1.1, 1.3 and 8.7.

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/theme_manager.dart';

/// Bottom navigation bar for the mock test runner.
///
/// * [canGoBack] — `true` when the current Teil is not the first Teil; controls
///   whether the Previous control is shown (Requirement 8.1).
/// * [canGoNext] — `true` when the current Teil is not the final Teil; controls
///   whether the Next control is enabled (Requirement 8.2 / 8.3).
/// * [isFinalTeil] — `true` on the last Teil; the only state in which the
///   separate Finish control is shown (Requirements 8.4, 8.6).
/// * [onPrevious] / [onNext] / [onFinish] — navigation callbacks.
class MockNavBar extends StatelessWidget {
  final bool canGoBack;
  final bool canGoNext;
  final bool isFinalTeil;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const MockNavBar({
    super.key,
    required this.canGoBack,
    required this.canGoNext,
    required this.isFinalTeil,
    required this.onPrevious,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2730) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Previous — hidden on the first Teil (Requirement 8.1).
          if (canGoBack) ...[
            Expanded(
              child: _PreviousButton(
                label: l.mockPreviousTeil,
                isDark: isDark,
                onPressed: onPrevious,
              ),
            ),
            const SizedBox(width: 12),
          ],
          // Next — always visible, but DISABLED on the final Teil. It never
          // turns into Finish (Requirement 8.3).
          Expanded(
            flex: 2,
            child: _NextButton(
              label: l.mockNextTeil,
              enabled: canGoNext,
              isDark: isDark,
              onPressed: onNext,
            ),
          ),
          // Finish — a separate, distinct control shown ONLY on the final Teil
          // (Requirements 8.4, 8.6).
          if (isFinalTeil) ...[
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _FinishButton(
                label: l.mockFinishTest,
                onPressed: onFinish,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Outlined Previous control, styled for the Design_System and dark mode.
class _PreviousButton extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onPressed;

  const _PreviousButton({
    required this.label,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(
          color: isDark ? Colors.white24 : AppColors.duoCardGrayShadow,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : AppColors.duoTextDark,
        ),
      ),
    );
  }
}

/// Next control. Uses the accent color when enabled and a muted, clearly
/// disabled appearance on the final Teil.
class _NextButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isDark;
  final VoidCallback onPressed;

  const _NextButton({
    required this.label,
    required this.enabled,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final accent = ThemeManager.accent;

    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        disabledBackgroundColor:
            isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
        disabledForegroundColor: isDark ? Colors.white38 : Colors.black38,
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Finish control — a distinct green action shown only on the final Teil so it
/// reads clearly as the deliberate "complete the test" choice (Requirement 8.4).
class _FinishButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _FinishButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.duoGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
