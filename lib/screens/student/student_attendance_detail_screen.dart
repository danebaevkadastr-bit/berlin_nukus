import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/gamified_card.dart';

class StudentAttendanceDetailScreen extends StatefulWidget {
  const StudentAttendanceDetailScreen({super.key});

  @override
  State<StudentAttendanceDetailScreen> createState() =>
      _StudentAttendanceDetailScreenState();
}

class _StudentAttendanceDetailScreenState
    extends State<StudentAttendanceDetailScreen> {
  // Each record: {date, attended, lessonType, topic, groupName}
  List<_AttendanceRecord> _records = [];
  bool _isLoading = true;
  int _totalLessons = 0;
  int _attendedCount = 0;
  int _missedCount = 0;

  /// Filter: 'all' | 'attended' | 'missed'
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid =
        Provider.of<UserProvider>(context, listen: false).uid;
    final groups =
        await FirebaseService().getStudentGroupsStream(uid).first;

    final records = <_AttendanceRecord>[];

    for (final group in groups) {
      final groupName = group['name'] as String? ?? '';
      final lessons =
          group['lessons'] as Map<String, dynamic>? ?? {};

      for (final entry in lessons.entries) {
        final dateKey = entry.key;
        final lesson = entry.value as Map<String, dynamic>;

        final attendance =
            lesson['attendance'] as Map<String, dynamic>? ?? {};
        if (!attendance.containsKey(uid)) continue; // not in this lesson

        final attended = attendance[uid] == true;
        final lessonType =
            lesson['lessonType'] as String? ?? 'Dars';
        final topic = lesson['topic'] as String? ?? '';

        records.add(_AttendanceRecord(
          dateKey: dateKey,
          attended: attended,
          lessonType: lessonType,
          topic: topic,
          groupName: groupName,
        ));
      }
    }

    // Sort newest first
    records.sort((a, b) => b.dateKey.compareTo(a.dateKey));

    if (mounted) {
      setState(() {
        _records = records;
        _totalLessons = records.length;
        _attendedCount = records.where((r) => r.attended).length;
        _missedCount = records.where((r) => !r.attended).length;
        _isLoading = false;
      });
    }
  }

  String _fmtDate(String key) {
    final parts = key.split('-');
    if (parts.length == 3) return '${parts[2]}.${parts[1]}.${parts[0]}';
    return key;
  }

  /// Color & icon for lesson type
  _TypeStyle _typeStyle(String type) {
    final t = type.toLowerCase();
    if (t.contains('hören') || t.contains('horen')) {
      return _TypeStyle(
          color: AppColors.duoBlue,
          bg: AppColors.duoBlue.withValues(alpha: 0.13),
          icon: Icons.headphones_rounded);
    }
    if (t.contains('sprechen')) {
      return _TypeStyle(
          color: AppColors.duoGreen,
          bg: AppColors.duoGreen.withValues(alpha: 0.13),
          icon: Icons.record_voice_over_rounded);
    }
    if (t.contains('schreiben')) {
      return _TypeStyle(
          color: AppColors.duoPurple,
          bg: AppColors.duoPurple.withValues(alpha: 0.13),
          icon: Icons.edit_rounded);
    }
    if (t.contains('lesen')) {
      return _TypeStyle(
          color: AppColors.duoOrange,
          bg: AppColors.duoOrange.withValues(alpha: 0.13),
          icon: Icons.menu_book_rounded);
    }
    if (t.contains('grammatik') || t.contains('gramma')) {
      return _TypeStyle(
          color: const Color(0xFF8B5CF6),
          bg: const Color(0xFF8B5CF6).withValues(alpha: 0.13),
          icon: Icons.spellcheck_rounded);
    }
    // default
    return _TypeStyle(
        color: AppColors.duoBlue,
        bg: AppColors.duoBlue.withValues(alpha: 0.13),
        icon: Icons.school_rounded);
  }

  List<_AttendanceRecord> get _filtered {
    if (_filter == 'attended') return _records.where((r) => r.attended).toList();
    if (_filter == 'missed') return _records.where((r) => !r.attended).toList();
    return _records;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final l = AppLocalizations.of(context);
    final attendancePct = _totalLessons > 0
        ? (_attendedCount / _totalLessons * 100).round()
        : 0;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.duoTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.attendance.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.duoGreen))
          : Column(
              children: [
                // ── Summary card ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: GamifiedCard(
                    padding: const EdgeInsets.all(20),
                    color: isDark
                        ? AppColors.duoCardGray.withValues(alpha: 0.07)
                        : Colors.white,
                    shadowColor: isDark
                        ? Colors.black26
                        : AppColors.duoCardGrayShadow,
                    child: Row(
                      children: [
                        // Circular progress
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: _totalLessons > 0
                                    ? _attendedCount / _totalLessons
                                    : 0,
                                strokeWidth: 7,
                                backgroundColor: isDark
                                    ? Colors.white12
                                    : AppColors.duoCardGrayShadow,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        AppColors.duoGreen),
                                strokeCap: StrokeCap.round,
                              ),
                              Center(
                                child: Text(
                                  '$attendancePct%',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.duoTextDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SummaryRow(
                                label: l.totalLessons,
                                value: '$_totalLessons',
                                color: isDark
                                    ? Colors.white
                                    : AppColors.duoTextDark,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 6),
                              _SummaryRow(
                                label: l.attended,
                                value: '$_attendedCount',
                                color: AppColors.duoGreen,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 6),
                              _SummaryRow(
                                label: l.notAttended,
                                value: '$_missedCount',
                                color: AppColors.duoRed,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Filter chips ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: l.all,
                        selected: _filter == 'all',
                        color: AppColors.duoBlue,
                        isDark: isDark,
                        onTap: () => setState(() => _filter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: l.attended,
                        selected: _filter == 'attended',
                        color: AppColors.duoGreen,
                        isDark: isDark,
                        onTap: () => setState(() => _filter = 'attended'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: l.notAttended,
                        selected: _filter == 'missed',
                        color: AppColors.duoRed,
                        isDark: isDark,
                        onTap: () => setState(() => _filter = 'missed'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── List ──
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text(
                            _totalLessons == 0
                                ? 'Hali davomat ma\'lumoti yo\'q'
                                : 'Bu filtrdagi darslar yo\'q',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white38
                                  : AppColors.duoTextLight,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) {
                            final rec = _filtered[i];
                            final ts = _typeStyle(rec.lessonType);
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10),
                              child: GamifiedCard(
                                padding: const EdgeInsets.all(16),
                                color: isDark
                                    ? AppColors.duoCardGray
                                        .withValues(alpha: 0.07)
                                    : Colors.white,
                                shadowColor: isDark
                                    ? Colors.black26
                                    : AppColors.duoCardGrayShadow,
                                child: Row(
                                  children: [
                                    // Lesson type icon badge
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: ts.bg,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: Icon(ts.icon,
                                          color: ts.color, size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                _fmtDate(rec.dateKey),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w900,
                                                  color: isDark
                                                      ? Colors.white
                                                      : AppColors
                                                          .duoTextDark,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: ts.bg,
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(8),
                                                ),
                                                child: Text(
                                                  rec.lessonType
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w900,
                                                    color: ts.color,
                                                    letterSpacing: 0.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (rec.topic.isNotEmpty) ...[
                                            const SizedBox(height: 3),
                                            Text(
                                              rec.topic,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color: isDark
                                                    ? Colors.white60
                                                    : AppColors
                                                        .duoTextLight,
                                              ),
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ],
                                          if (rec.groupName.isNotEmpty) ...[
                                            const SizedBox(height: 3),
                                            Text(
                                              rec.groupName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color: isDark
                                                    ? Colors.white38
                                                    : AppColors
                                                        .duoTextLight
                                                        .withValues(
                                                            alpha: 0.6),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // Attendance badge
                                    const SizedBox(width: 8),
                                    Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: rec.attended
                                                ? AppColors.duoGreen
                                                    .withValues(alpha: 0.15)
                                                : AppColors.duoRed
                                                    .withValues(
                                                        alpha: 0.13),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            rec.attended
                                                ? Icons
                                                    .check_circle_rounded
                                                : Icons.cancel_rounded,
                                            color: rec.attended
                                                ? AppColors.duoGreen
                                                : AppColors.duoRed,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          rec.attended ? '✓' : '✗',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            color: rec.attended
                                                ? AppColors.duoGreen
                                                : AppColors.duoRed,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

// ── Data model ──────────────────────────────────────────────────────────────

class _AttendanceRecord {
  final String dateKey;
  final bool attended;
  final String lessonType;
  final String topic;
  final String groupName;

  _AttendanceRecord({
    required this.dateKey,
    required this.attended,
    required this.lessonType,
    required this.topic,
    required this.groupName,
  });
}

class _TypeStyle {
  final Color color;
  final Color bg;
  final IconData icon;
  const _TypeStyle({
    required this.color,
    required this.bg,
    required this.icon,
  });
}

// ── Small widgets ────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : AppColors.duoTextLight,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.15)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected
                ? color
                : (isDark ? Colors.white54 : AppColors.duoTextLight),
          ),
        ),
      ),
    );
  }
}
