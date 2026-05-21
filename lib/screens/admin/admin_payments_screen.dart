import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/gamified_card.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';

// ==================== ENTRY: Course List ====================

class AdminPaymentsScreen extends StatelessWidget {
  const AdminPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'TO\'LOVLAR',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.duoTextDark,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.duoOrange));
          }
          final courses = snapshot.data?.docs ?? [];
          if (courses.isEmpty) return _emptyState(isDark, 'Kurslar topilmadi', Icons.school_rounded);

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index].data() as Map<String, dynamic>;
              final courseId = courses[index].id;
              final courseTitle = course['title'] ?? 'Noma\'lum';
              final type = course['type'] ?? 'Offline';
              final color = type == 'Online' ? AppColors.duoOrange : AppColors.duoBlue;
              final shadowColor = type == 'Online' ? AppColors.duoOrangeShadow : AppColors.duoBlueShadow;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GamifiedCard(
                  padding: const EdgeInsets.all(20),
                  color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                  shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => _PaymentGroupsScreen(courseId: courseId, courseTitle: courseTitle),
                  )),
                  child: Row(
                    children: [
                      Container(
                        height: 48, width: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: shadowColor, width: 1.5),
                        ),
                        child: Icon(type == 'Online' ? Icons.laptop_rounded : Icons.flag_rounded, color: color, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(courseTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.duoTextDark)),
                            const SizedBox(height: 4),
                            Text(type.toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.duoTextLight)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white54 : AppColors.duoTextLight),
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

  static Widget _emptyState(bool isDark, String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: isDark ? Colors.white24 : AppColors.duoCardGray),
          const SizedBox(height: 16),
          Text(msg, style: TextStyle(color: isDark ? Colors.white70 : AppColors.duoTextLight, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ==================== Groups List ====================

class _PaymentGroupsScreen extends StatelessWidget {
  final String courseId;
  final String courseTitle;
  const _PaymentGroupsScreen({required this.courseId, required this.courseTitle});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(courseTitle.toUpperCase(), style: TextStyle(color: isDark ? Colors.white : AppColors.duoTextDark, fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').where('courseId', isEqualTo: courseId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.duoOrange));
          }
          final groups = snapshot.data?.docs ?? [];
          if (groups.isEmpty) return AdminPaymentsScreen._emptyState(isDark, 'Guruhlar topilmadi', Icons.group_rounded);

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index].data() as Map<String, dynamic>;
              final groupId = groups[index].id;
              final groupName = group['name'] ?? 'Noma\'lum';
              final studentIds = List<String>.from(group['students'] ?? []);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GamifiedCard(
                  padding: const EdgeInsets.all(20),
                  color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                  shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => _PaymentStudentsScreen(groupId: groupId, groupName: groupName, studentIds: studentIds),
                  )),
                  child: Row(
                    children: [
                      Container(
                        height: 48, width: 48,
                        decoration: BoxDecoration(color: AppColors.duoPurple.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.group_rounded, color: AppColors.duoPurple, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(groupName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.duoTextDark)),
                            const SizedBox(height: 4),
                            Text('${studentIds.length} ta student', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.duoTextLight)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white54 : AppColors.duoTextLight),
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
}

// ==================== Students List ====================

class _PaymentStudentsScreen extends StatelessWidget {
  final String groupId;
  final String groupName;
  final List<String> studentIds;
  const _PaymentStudentsScreen({required this.groupId, required this.groupName, required this.studentIds});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text('$groupName — STUDENTLAR', style: TextStyle(color: isDark ? Colors.white : AppColors.duoTextDark, fontWeight: FontWeight.w900, fontSize: 15)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
      ),
      body: studentIds.isEmpty
          ? AdminPaymentsScreen._emptyState(isDark, 'Guruhda studentlar yo\'q', Icons.person_rounded)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              itemCount: studentIds.length,
              itemBuilder: (context, index) {
                return _StudentPaymentTile(studentId: studentIds[index], groupId: groupId, isDark: isDark);
              },
            ),
    );
  }
}

class _StudentPaymentTile extends StatelessWidget {
  final String studentId;
  final String groupId;
  final bool isDark;
  const _StudentPaymentTile({required this.studentId, required this.groupId, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Padding(padding: EdgeInsets.only(bottom: 16), child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator(color: AppColors.duoOrange))));

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final name = data['fullName'] ?? 'Noma\'lum';
        final phone = data['phone'] ?? '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GamifiedCard(
            padding: const EdgeInsets.all(20),
            color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
            shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => _StudentPaymentHistoryScreen(studentId: studentId, studentName: name, groupId: groupId),
            )),
            child: Row(
              children: [
                Container(
                  height: 48, width: 48,
                  decoration: BoxDecoration(color: AppColors.duoGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.person_rounded, color: AppColors.duoGreen, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.duoTextDark)),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(phone, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.duoTextLight)),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white54 : AppColors.duoTextLight),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==================== Student Payment History + Admin Actions ====================

class _StudentPaymentHistoryScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String groupId;
  const _StudentPaymentHistoryScreen({required this.studentId, required this.studentName, required this.groupId});

  @override
  State<_StudentPaymentHistoryScreen> createState() => _StudentPaymentHistoryScreenState();
}

class _StudentPaymentHistoryScreenState extends State<_StudentPaymentHistoryScreen> {
  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  String _fmtPeriod(Timestamp? s, Timestamp? e) {
    if (s == null || e == null) return 'Period noma\'lum';
    return '${_fmtDate(s.toDate())} – ${_fmtDate(e.toDate())}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(widget.studentName.toUpperCase(),
            style: TextStyle(color: isDark ? Colors.white : AppColors.duoTextDark, fontWeight: FontWeight.w900, fontSize: 15)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
        actions: [
          // Naqd to'lov qo'shish tugmasi
          TextButton.icon(
            onPressed: () => _showAddCashPaymentSheet(context),
            icon: const Icon(Icons.add_rounded, color: AppColors.duoGreen, size: 20),
            label: const Text('NAQD', style: TextStyle(color: AppColors.duoGreen, fontWeight: FontWeight.w900, fontSize: 13)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payments')
            .where('studentId', isEqualTo: widget.studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.duoOrange));
          }
          var payments = snapshot.data?.docs.toList() ?? [];
          payments.sort((a, b) {
            final ta = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final tb = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (ta == null && tb == null) return 0;
            if (ta == null) return -1;
            if (tb == null) return 1;
            return tb.compareTo(ta);
          });
          if (payments.isEmpty) {
            return AdminPaymentsScreen._emptyState(isDark, 'To\'lov tarixi yo\'q', Icons.receipt_long_rounded);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final doc = payments[index];
              final p = doc.data() as Map<String, dynamic>;
              final paymentId = doc.id;
              final status = p['status'] ?? 'pending';
              final type = p['type'] ?? 'card';
              final periodText = _fmtPeriod(p['periodStart'] as Timestamp?, p['periodEnd'] as Timestamp?);
              final note = p['note'] ?? '';
              final adminNote = p['adminNote'] ?? '';
              final hasMockReceipt = p['receiptMock'] == true;

              Color statusColor;
              String statusText;
              IconData statusIcon;
              switch (status) {
                case 'accepted':
                  statusColor = AppColors.duoGreen;
                  statusText = 'QABUL QILINDI';
                  statusIcon = Icons.check_circle_rounded;
                  break;
                case 'rejected':
                  statusColor = AppColors.duoRed;
                  statusText = 'BEKOR QILINDI';
                  statusIcon = Icons.cancel_rounded;
                  break;
                default:
                  statusColor = AppColors.duoOrange;
                  statusText = 'KUTILMOQDA';
                  statusIcon = Icons.pending_rounded;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GamifiedCard(
                  padding: const EdgeInsets.all(18),
                  color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                  shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: statusColor.withValues(alpha: 0.12)),
                            child: Icon(statusIcon, color: statusColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(periodText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.duoTextDark)),
                                const SizedBox(height: 3),
                                Text(
                                  type == 'cash' ? 'NAQD' : 'PLASTIK (KARTA)',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isDark ? Colors.white38 : AppColors.duoTextLight),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: statusColor.withValues(alpha: 0.12)),
                            child: Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor)),
                          ),
                        ],
                      ),

                      // Student note
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _infoRow(isDark, Icons.comment_rounded, 'IZOH', note),
                      ],

                      // Receipt (mock)
                      if (type == 'card') ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: hasMockReceipt
                                ? AppColors.duoGreen.withValues(alpha: 0.08)
                                : AppColors.duoRed.withValues(alpha: 0.08),
                            border: Border.all(
                              color: hasMockReceipt ? AppColors.duoGreen.withValues(alpha: 0.3) : AppColors.duoRed.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hasMockReceipt ? Icons.receipt_rounded : Icons.receipt_long_outlined,
                                color: hasMockReceipt ? AppColors.duoGreen : AppColors.duoRed,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                hasMockReceipt ? 'Chek biriktirilgan' : 'Chek biriktirilmagan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: hasMockReceipt ? AppColors.duoGreen : AppColors.duoRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Admin note (if exists)
                      if (adminNote.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _infoRow(isDark, Icons.admin_panel_settings_rounded, 'ADMIN IZOHI', adminNote, color: statusColor),
                      ],

                      // Pending card actions
                      if (status == 'pending' && type == 'card') ...[
                        const SizedBox(height: 16),
                        _AdminActionSection(
                          paymentId: paymentId,
                          onDone: () => setState(() {}),
                        ),
                      ],

                      // Cash payment: just show confirmation info
                      if (status == 'pending' && type == 'cash') ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Naqd to\'lov — tasdiqlash kutilmoqda',
                          style: TextStyle(fontSize: 12, color: AppColors.duoOrange, fontWeight: FontWeight.w600),
                        ),
                      ],
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

  Widget _infoRow(bool isDark, IconData icon, String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color ?? (isDark ? Colors.white38 : AppColors.duoTextLight)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? Colors.white30 : AppColors.duoTextLight)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? (isDark ? Colors.white70 : AppColors.duoTextDark))),
            ],
          ),
        ),
      ],
    );
  }

  // ── Naqd to'lov qo'shish (admin)
  void _showAddCashPaymentSheet(BuildContext context) async {
    final isDark = ThemeManager.isDark;
    final noteController = TextEditingController();
    List<_Period> periods = [];
    int selectedIdx = 0;

    // Get group start date
    try {
      final doc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
      final data = doc.data() ?? {};
      final startedTs = data['started'];
      DateTime startDate = startedTs is Timestamp ? startedTs.toDate() : DateTime.now().subtract(const Duration(days: 60));
      final now = DateTime.now();
      DateTime cursor = startDate;
      while (cursor.isBefore(now) || periods.isEmpty) {
        periods.add(_Period(start: cursor, end: cursor.add(const Duration(days: 30))));
        cursor = cursor.add(const Duration(days: 30));
        if (periods.length > 24) break;
      }
    } catch (_) {
      periods = [_Period(start: DateTime.now(), end: DateTime.now().add(const Duration(days: 30)))];
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final cardBg = isDark ? const Color(0xFF131F24) : Colors.white;
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 50, height: 6, decoration: BoxDecoration(color: AppColors.duoCardGrayShadow, borderRadius: BorderRadius.circular(20)))),
                  const SizedBox(height: 20),
                  Text('NAQD TO\'LOV QO\'SHISH', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.duoTextDark)),
                  const SizedBox(height: 6),
                  Text(widget.studentName, style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : AppColors.duoTextLight, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),

                  // Period scroll
                  Text('PERIOD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isDark ? Colors.white54 : AppColors.duoTextLight, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 82,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: periods.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        if (i == periods.length) {
                          return GestureDetector(
                            onTap: () {
                              final last = periods.last;
                              setModal(() {
                                periods.add(_Period(start: last.end, end: last.end.add(const Duration(days: 30))));
                                selectedIdx = periods.length - 1;
                              });
                            },
                            child: Container(
                              width: 56,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.duoGreen, width: 2), color: AppColors.duoGreen.withValues(alpha: 0.08)),
                              child: const Center(child: Icon(Icons.add_rounded, color: AppColors.duoGreen, size: 28)),
                            ),
                          );
                        }
                        final p = periods[i];
                        final sel = selectedIdx == i;
                        return GestureDetector(
                          onTap: () => setModal(() => selectedIdx = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 138,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: sel ? AppColors.duoGreen : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white),
                              border: Border.all(color: sel ? AppColors.duoGreenShadow : (isDark ? Colors.white12 : AppColors.duoCardGrayShadow), width: 2),
                              boxShadow: sel ? const [BoxShadow(color: AppColors.duoGreenShadow, offset: Offset(0, 4))] : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_fmtDate(p.start), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: sel ? Colors.white : (isDark ? Colors.white : AppColors.duoTextDark))),
                                Text('–', style: TextStyle(fontSize: 11, color: sel ? Colors.white60 : AppColors.duoTextLight)),
                                Text(_fmtDate(p.end), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: sel ? Colors.white : (isDark ? Colors.white : AppColors.duoTextDark))),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Note field
                  Text('IZOH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isDark ? Colors.white54 : AppColors.duoTextLight, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    style: TextStyle(color: isDark ? Colors.white : AppColors.duoTextDark, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Masalan: Aprel oyi naqd to\'lovi...',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : AppColors.duoTextLight),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.duoBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.duoGreen, width: 2)),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: GamifiedCard(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: AppColors.duoGreen,
                      shadowColor: AppColors.duoGreenShadow,
                      shadowDepth: 4,
                      onTap: () async {
                        final period = periods[selectedIdx];
                        final periodStart = Timestamp.fromDate(period.start);
                        final existingSnap = await FirebaseFirestore.instance
                            .collection('payments')
                            .where('studentId', isEqualTo: widget.studentId)
                            .get();
                        final hasActivePayment = existingSnap.docs.any((doc) {
                          final data = doc.data();
                          final status = data['status'] as String? ?? '';
                          if (status == 'rejected') return false;
                          final existingStart = data['periodStart'] as Timestamp?;
                          return existingStart != null && existingStart == periodStart;
                        });
                        if (hasActivePayment) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              content: const Text('Bu davr uchun allaqachon to\'lov kiritilgan!', style: TextStyle(fontWeight: FontWeight.bold)),
                              backgroundColor: AppColors.duoOrange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ));
                          }
                          return;
                        }
                        
                        await FirebaseFirestore.instance.collection('payments').add({
                          'studentId': widget.studentId,
                          'groupId': widget.groupId,
                          'periodStart': Timestamp.fromDate(period.start),
                          'periodEnd': Timestamp.fromDate(period.end),
                          'type': 'cash',
                          'note': noteController.text.trim(),
                          'adminNote': 'Admin tomonidan qo\'shildi',
                          'receiptMock': false,
                          'status': 'accepted',
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Naqd to\'lov tasdiqlandi!', style: TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: AppColors.duoGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ));
                        }
                      },
                      child: const Center(child: Text('TASDIQLASH VA SAQLASH', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5))),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Admin action section (for pending card payments)
class _AdminActionSection extends StatefulWidget {
  final String paymentId;
  final VoidCallback onDone;
  const _AdminActionSection({required this.paymentId, required this.onDone});

  @override
  State<_AdminActionSection> createState() => _AdminActionSectionState();
}

class _AdminActionSectionState extends State<_AdminActionSection> {
  final TextEditingController _adminNoteCtrl = TextEditingController();

  @override
  void dispose() {
    _adminNoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _update(String status) async {
    await FirebaseFirestore.instance.collection('payments').doc(widget.paymentId).update({
      'status': status,
      'adminNote': _adminNoteCtrl.text.trim(),
    });
    if (mounted) {
      final color = status == 'accepted' ? AppColors.duoGreen : AppColors.duoRed;
      final msg = status == 'accepted' ? 'To\'lov qabul qilindi!' : 'To\'lov bekor qilindi';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ADMIN IZOHI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isDark ? Colors.white54 : AppColors.duoTextLight, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: _adminNoteCtrl,
          style: TextStyle(color: isDark ? Colors.white : AppColors.duoTextDark, fontWeight: FontWeight.w600, fontSize: 13),
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Izoh yozing (ixtiyoriy)...',
            hintStyle: TextStyle(color: isDark ? Colors.white30 : AppColors.duoTextLight, fontSize: 13),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.duoBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.duoBlue, width: 2)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _update('rejected'),
                icon: const Icon(Icons.close_rounded, color: AppColors.duoRed, size: 18),
                label: const Text('BEKOR QILISH', style: TextStyle(color: AppColors.duoRed, fontWeight: FontWeight.w900, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: AppColors.duoRed, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _update('accepted'),
                icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                label: const Text('QABUL QILISH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.duoGreen,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Period {
  final DateTime start;
  final DateTime end;
  _Period({required this.start, required this.end});
}
