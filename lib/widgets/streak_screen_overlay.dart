import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_colors.dart';
import '../utils/theme_manager.dart';
import 'animated_flame_widget.dart';
import 'gamified_button.dart';
import '../services/sound_service.dart';
import '../services/haptic_service.dart';

/// Kunlik Seriya Modal Ekrani (Duolingo Rasmiga 100% Mos Yechim).
class StreakScreenOverlay extends StatefulWidget {
  final int streakDays;
  final VoidCallback onDismiss;

  const StreakScreenOverlay({
    super.key,
    required this.streakDays,
    required this.onDismiss,
  });

  @override
  State<StreakScreenOverlay> createState() => _StreakScreenOverlayState();
}

class _StreakScreenOverlayState extends State<StreakScreenOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _popCtrl;
  late final Animation<double> _popAnim;
  bool _isIgnited = false;

  @override
  void initState() {
    super.initState();
    _popCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _popAnim = CurvedAnimation(
      parent: _popCtrl,
      curve: Curves.elasticOut,
    );

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) {
        setState(() => _isIgnited = true);
        _popCtrl.forward();
        SoundService.playCorrect();
        HapticService.mediumImpact();
      }
    });
  }

  @override
  void dispose() {
    _popCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);

    // Bugungi hafta kuni (0 = Dsh, 6 = Yak)
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;

    final weekDays = ['Dsh', 'Ssh', 'Chsh', 'Psh', 'Jum', 'Shb', 'Yak'];

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Qorong'u orqa fon
          GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              color: Colors.black.withValues(alpha: 0.65),
            ),
          ),

          // Markazdagi Duolingo Karta
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF19272E) : Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Aynan Duolingo 3D Olov Animatsiyasi
                    AnimatedFlameWidget(
                      size: 210,
                      onIgnited: () {
                        if (mounted && !_isIgnited) {
                          setState(() => _isIgnited = true);
                          _popCtrl.forward();
                        }
                      },
                    ),

                    const SizedBox(height: 28),

                    // 2. Sarlavha: "SERIYA X KUN"
                    ScaleTransition(
                      scale: _popAnim,
                      child: Column(
                        children: [
                          Text(
                            'SERIYA ${widget.streakDays} KUN',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                              color: isDark ? Colors.white : const Color(0xFF2C3437),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.keepLearningDaily,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white60 : const Color(0xFF8392A5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 3. Hafta kunlari qatori (Rasmga mos ravishda)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (index) {
                        final isToday = index == todayIndex;
                        final isPast = index < todayIndex;

                        return Column(
                          children: [
                            // Kunning qisqa nomi
                            Text(
                              weekDays[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                                color: isToday
                                    ? AppColors.duoOrange
                                    : (isDark ? Colors.white38 : const Color(0xFFAFAFAF)),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Kun doirasi
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isToday ? 38 : 34,
                              height: isToday ? 38 : 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isToday
                                    ? AppColors.duoOrange
                                    : (isPast
                                        ? AppColors.duoOrange.withValues(alpha: 0.25)
                                        : (isDark ? Colors.white10 : const Color(0xFFF0F4F8))),
                                boxShadow: isToday
                                    ? [
                                        BoxShadow(
                                          color: AppColors.duoOrange.withValues(alpha: 0.45),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: isToday
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      )
                                    : (isPast
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: AppColors.duoOrange,
                                            size: 16,
                                          )
                                        : const SizedBox.shrink()),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 36),

                    // 4. "DAVOM ETISH" 3D Tugmasi
                    SizedBox(
                      width: double.infinity,
                      child: GamifiedButton(
                        text: 'DAVOM ETISH',
                        onPressed: () {
                          HapticService.lightImpact();
                          widget.onDismiss();
                        },
                        color: AppColors.duoBlue,
                        shadowColor: AppColors.duoBlueShadow,
                        height: 54,
                        borderRadius: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
