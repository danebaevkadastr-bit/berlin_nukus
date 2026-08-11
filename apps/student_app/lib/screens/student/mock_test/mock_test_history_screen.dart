import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:core/services/mock_test_history_service.dart';
import 'package:core/utils/app_colors.dart';
import 'package:core/utils/theme_manager.dart';
import 'package:core/widgets/gamified_card.dart';

class MockTestHistoryScreen extends StatelessWidget {
  const MockTestHistoryScreen({super.key});

  String _fmtDate(dynamic ts) {
    if (ts is! Timestamp) return '';
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  void _showDetail(BuildContext context, Map<String, dynamic> item, int number, bool isDark) {
    final total = (item['totalPoints'] as num?)?.toInt() ?? 0;
    final max = (item['totalMax'] as num?)?.toInt() ?? 300;
    final pct = max > 0 ? (total / max * 100).round() : 0;
    final written = (item['writtenPoints'] as num?)?.toInt() ?? 0;
    final writtenMax = (item['writtenMax'] as num?)?.toInt() ?? 225;
    final oral = (item['oralPoints'] as num?)?.toInt() ?? 0;
    final oralMax = (item['oralMax'] as num?)?.toInt() ?? 75;
    final writtenPassed = item['writtenPassed'] == true;
    final oralPassed = item['oralPassed'] == true;
    final passed = writtenPassed && oralPassed;
    final date = _fmtDate(item['date']);
    final sectionPoints = item['sectionPoints'] as Map<String, dynamic>? ?? {};

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2A32) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 40, height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : AppColors.duoCardGrayShadow,
                borderRadius: BorderRadius.circular(3)),
            )),
            const SizedBox(height: 16),
            Row(children: [
              Text('#$number', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.duoTextDark)),
              const SizedBox(width: 12),
              Text('B1 Sinov imtihoni', style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white70 : AppColors.duoTextLight)),
              const Spacer(),
              if (date.isNotEmpty) Text(date, style: TextStyle(fontSize: 13,
                  color: isDark ? Colors.white54 : AppColors.duoTextLight)),
            ]),
            const SizedBox(height: 16),
            // Umumiy natija
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (passed ? AppColors.duoGreen : AppColors.duoRed).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (passed ? AppColors.duoGreen : AppColors.duoRed).withValues(alpha: 0.4)),
              ),
              child: Column(children: [
                Text('$total / $max ($pct%)', style: TextStyle(fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: passed ? AppColors.duoGreen : AppColors.duoRed)),
                const SizedBox(height: 4),
                Text(passed ? 'O\'tdi' : 'O\'tmadi', style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: passed ? AppColors.duoGreen : AppColors.duoRed)),
              ]),
            ),
            const SizedBox(height: 16),
            // Yozma / Og'zaki
            Row(children: [
              Expanded(child: _detailBox('Yozma', '$written/$writtenMax', writtenPassed, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _detailBox('Og\'zaki', '$oral/$oralMax', oralPassed, isDark)),
            ]),
            // Section points
            if (sectionPoints.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Bo\'limlar bo\'yicha', style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white54 : AppColors.duoTextLight)),
              const SizedBox(height: 8),
              ...sectionPoints.entries.map((e) {
                final name = _sectionLabel(e.key);
                final pts = (e.value as num?)?.toInt() ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.duoTextLight)),
                    Text('$pts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.duoTextDark)),
                  ]),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  String _sectionLabel(String key) {
    switch (key) {
      case 'leseverstehen': return 'Leseverstehen';
      case 'sprachbausteine': return 'Sprachbausteine';
      case 'hoerverstehen': return 'Hörverstehen';
      case 'schriftlicherAusdruck': return 'Schriftlicher Ausdruck';
      case 'muendlicherAusdruck': return 'Mündlicher Ausdruck';
      default: return key;
    }
  }

  Widget _detailBox(String label, String value, bool passed, bool isDark) {
    final color = passed ? AppColors.duoGreen : AppColors.duoRed;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Icon(passed ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 20, color: color),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark)),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white54 : AppColors.duoTextLight)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : AppColors.duoTextDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tarix',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: MockTestHistoryService.stream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.duoBlue));
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded,
                      size: 56,
                      color: isDark
                          ? Colors.white24
                          : AppColors.duoTextLight.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text(
                    'Hali imtihon topshirilmagan',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final item = list[i];
              final total = (item['totalPoints'] as num?)?.toInt() ?? 0;
              final max = (item['totalMax'] as num?)?.toInt() ?? 300;
              final pct = max > 0 ? (total / max * 100).round() : 0;
              final written = (item['writtenPoints'] as num?)?.toInt() ?? 0;
              final writtenMax = (item['writtenMax'] as num?)?.toInt() ?? 225;
              final oral = (item['oralPoints'] as num?)?.toInt() ?? 0;
              final oralMax = (item['oralMax'] as num?)?.toInt() ?? 75;
              final writtenPassed = item['writtenPassed'] == true;
              final oralPassed = item['oralPassed'] == true;
              final passed = writtenPassed && oralPassed;
              final date = _fmtDate(item['date']);

              final scoreColor = pct >= 60
                  ? AppColors.duoGreen
                  : pct >= 40
                      ? AppColors.duoOrange
                      : AppColors.duoRed;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GamifiedCard(
                  padding: const EdgeInsets.all(18),
                  color: isDark
                      ? AppColors.duoCardGray.withValues(alpha: 0.1)
                      : Colors.white,
                  shadowColor:
                      isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                  onTap: () => _showDetail(context, item, i + 1, isDark),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          // Raqam badge
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: scoreColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: scoreColor, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: scoreColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'B1 Sinov imtihoni',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.duoTextDark,
                                  ),
                                ),
                                if (date.isNotEmpty)
                                  Text(
                                    date,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white54
                                          : AppColors.duoTextLight,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Umumiy ball
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: scoreColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: scoreColor.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              '$total/$max',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: scoreColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: max > 0 ? total / max : 0,
                          backgroundColor: isDark
                              ? Colors.white12
                              : AppColors.duoCardGrayShadow,
                          color: scoreColor,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Written / Oral
                      Row(
                        children: [
                          _partBadge('Yozma', '$written/$writtenMax',
                              writtenPassed, isDark),
                          const SizedBox(width: 10),
                          _partBadge('Og\'zaki', '$oral/$oralMax',
                              oralPassed, isDark),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: passed
                                  ? AppColors.duoGreen.withValues(alpha: 0.12)
                                  : AppColors.duoRed.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              passed ? 'O\'tdi' : 'O\'tmadi',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: passed
                                    ? AppColors.duoGreen
                                    : AppColors.duoRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _partBadge(
      String label, String value, bool passed, bool isDark) {
    final color = passed ? AppColors.duoGreen : AppColors.duoRed;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : AppColors.duoTextLight,
          ),
        ),
      ],
    );
  }
}
