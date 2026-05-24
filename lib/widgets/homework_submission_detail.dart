import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Talaba uy vazifasi topshirig‘i (izoh, test javoblari).
class HomeworkSubmissionDetail extends StatelessWidget {
  final Map<String, dynamic> submission;
  final List<dynamic> homeworks;
  final bool isDark;

  const HomeworkSubmissionDetail({
    super.key,
    required this.submission,
    required this.homeworks,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final note = (submission['note'] as String?)?.trim() ?? '';
    final testGrades = submission['testGrades'] as Map<String, dynamic>?;
    final submittedAt = submission['submittedAt'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (submittedAt != null && submittedAt.isNotEmpty)
          _line('Vaqt', _fmtSubmittedAt(submittedAt)),
        if (note.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'IZOH',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white54 : AppColors.duoTextLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.duoTextDark,
              height: 1.4,
            ),
          ),
        ],
        if (testGrades != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.duoOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Test: ${testGrades['correctCount'] ?? 0}/${testGrades['totalCount'] ?? 0} to\'g\'ri',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.duoOrange,
              ),
            ),
          ),
          ..._buildHwResults(testGrades),
        ],
        if (note.isEmpty && testGrades == null)
          Text(
            'Qo\'shimcha ma\'lumot yo\'q',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white38 : AppColors.duoTextLight,
            ),
          ),
      ],
    );
  }

  List<Widget> _buildHwResults(Map<String, dynamic> testGrades) {
    final hwResults = testGrades['hwResults'] as Map<String, dynamic>? ?? {};
    if (hwResults.isEmpty) return [];

    final widgets = <Widget>[];
    hwResults.forEach((key, value) {
      if (value is! Map<String, dynamic>) return;
      final idxStr = key.replaceFirst('hw_', '');
      final idx = int.tryParse(idxStr) ?? 0;
      final hwTitle = idx < homeworks.length
          ? ((homeworks[idx] as Map?)?['title'] as String? ?? 'Uy vazifa ${idx + 1}')
          : 'Uy vazifa ${idx + 1}';

      final studentRaw = value['studentRaw'] as String? ?? '';
      final graded = value['graded'] as List<dynamic>? ?? [];

      widgets.add(const SizedBox(height: 12));
      widgets.add(
        Text(
          hwTitle.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white54 : AppColors.duoTextLight,
            letterSpacing: 0.4,
          ),
        ),
      );
      if (studentRaw.isNotEmpty) {
        widgets.add(const SizedBox(height: 4));
        widgets.add(
          Text(
            'Javoblar: $studentRaw',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
          ),
        );
      }
      if (graded.isNotEmpty) {
        final List<Widget> boxes = [];
        for (final g in graded) {
          if (g is! Map) continue;
          final q = g['q']?.toString() ?? '?';
          final stu = (g['student'] as String?)?.isNotEmpty == true
              ? (g['student'] as String).toLowerCase()
              : '?';
          final exp = (g['expected'] as String?)?.toLowerCase() ?? '';
          final ok = g['isCorrect'] == true;
          
          boxes.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ok ? AppColors.duoGreen.withValues(alpha: 0.15) : AppColors.duoRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ok ? AppColors.duoGreen : AppColors.duoRed, width: 1),
              ),
              child: Text(
                ok ? '$q$stu' : '$q$stu (To\'g\'risi: $exp)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: ok ? AppColors.duoGreen : AppColors.duoRed,
                ),
              ),
            ),
          );
        }

        if (boxes.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: boxes,
              ),
            ),
          );
        }
      }
    });
    return widgets;
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : AppColors.duoTextLight,
        ),
      ),
    );
  }

  String _fmtSubmittedAt(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
