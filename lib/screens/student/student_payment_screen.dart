import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/gamified_card.dart';

class StudentPaymentScreen extends StatefulWidget {
  final String studentId;
  const StudentPaymentScreen({super.key, required this.studentId});

  @override
  State<StudentPaymentScreen> createState() => _StudentPaymentScreenState();
}

class _StudentPaymentScreenState extends State<StudentPaymentScreen> {
  final TextEditingController _noteController = TextEditingController();

  List<_Period> _periods = [];
  int _selectedPeriodIndex = -1;
  bool _hasMockReceipt = false;
  bool _isLoading = true;
  bool _isSending = false;
  String? _groupId;
  DateTime? _groupStartDate;

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupData() async {
    try {
      final groupsSnap = await FirebaseFirestore.instance
          .collection('groups')
          .where('students', arrayContains: widget.studentId)
          .limit(1)
          .get();

      if (groupsSnap.docs.isNotEmpty) {
        final doc = groupsSnap.docs.first;
        _groupId = doc.id;
        final data = doc.data();
        final startedTs = data['started'];
        DateTime startDate;
        if (startedTs is Timestamp) {
          startDate = startedTs.toDate();
        } else {
          startDate = DateTime.now().subtract(const Duration(days: 60));
        }
        _buildPeriods(startDate);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _buildPeriods(DateTime startDate) {
    _periods = [];
    _selectedPeriodIndex = -1;
    _groupStartDate = startDate;
  }

  void _addNextPeriod() {
    if (_periods.isEmpty) {
      final start = _groupStartDate ?? DateTime.now().subtract(const Duration(days: 60));
      setState(() {
        _periods.add(_Period(start: start, end: start.add(const Duration(days: 30))));
        _selectedPeriodIndex = 0;
      });
    } else {
      final last = _periods.last;
      setState(() {
        _periods.add(_Period(
          start: last.end,
          end: last.end.add(const Duration(days: 30)),
        ));
        _selectedPeriodIndex = _periods.length - 1;
      });
    }
  }

  Future<void> _submitPayment() async {
    if (_selectedPeriodIndex < 0) {
      _showSnack('Iltimos, period tanlang', AppColors.duoOrange);
      return;
    }
    setState(() => _isSending = true);

    final period = _periods[_selectedPeriodIndex];

    try {
      final existingSnap = await FirebaseFirestore.instance.collection('payments')
          .where('studentId', isEqualTo: widget.studentId)
          .where('periodStart', isEqualTo: Timestamp.fromDate(period.start))
          .where('status', isNotEqualTo: 'rejected')
          .get();

      if (existingSnap.docs.isNotEmpty) {
        _showSnack('Bu davr uchun allaqachon to\'lov kiritilgan!', AppColors.duoOrange);
        setState(() => _isSending = false);
        return;
      }

      await FirebaseFirestore.instance.collection('payments').add({
        'studentId': widget.studentId,
        'groupId': _groupId ?? '',
        'periodStart': Timestamp.fromDate(period.start),
        'periodEnd': Timestamp.fromDate(period.end),
        'type': 'card',
        'note': _noteController.text.trim(),
        'adminNote': '',
        'receiptMock': _hasMockReceipt,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        _showSnack('To\'lov muvaffaqiyatli yuborildi!', AppColors.duoGreen);
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnack('Xatolik yuz berdi: $e', AppColors.duoRed);
    }
    if (mounted) setState(() => _isSending = false);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final bg = isDark ? const Color(0xFF131F24) : AppColors.duoBackground;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'TO\'LOV QO\'SHISH',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.duoTextDark,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.duoTextDark),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.duoOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Period sarlavhasi
                  _sectionTitle(isDark, Icons.calendar_month_rounded, 'PERIOD TANLANG'),
                  const SizedBox(height: 12),

                  // ── Gorizontal period scroll
                  SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _periods.length + 1, // +1 for add button
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (ctx, i) {
                        if (i == _periods.length) {
                          // + tugmasi
                          return GestureDetector(
                            onTap: _addNextPeriod,
                            child: Container(
                              width: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.duoGreen,
                                  width: 2,
                                ),
                                color: AppColors.duoGreen.withValues(alpha: 0.08),
                              ),
                              child: const Center(
                                child: Icon(Icons.add_rounded, color: AppColors.duoGreen, size: 32),
                              ),
                            ),
                          );
                        }
                        final p = _periods[i];
                        final isSelected = _selectedPeriodIndex == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPeriodIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 148,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: isSelected
                                  ? AppColors.duoGreen
                                  : (isDark
                                      ? AppColors.duoCardGray.withValues(alpha: 0.15)
                                      : Colors.white),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.duoGreenShadow
                                    : (isDark ? Colors.white12 : AppColors.duoCardGrayShadow),
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? const [BoxShadow(color: AppColors.duoGreenShadow, offset: Offset(0, 4), blurRadius: 0)]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fmtDate(p.start),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.duoTextDark),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '–',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white70 : (isDark ? Colors.white54 : AppColors.duoTextLight),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _fmtDate(p.end),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.duoTextDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Izoh
                  _sectionTitle(isDark, Icons.edit_note_rounded, 'IZOH (IXTIYORIY)'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Masalan: Aprel oyi to\'lovi...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : AppColors.duoTextLight,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.duoGreen, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Chek biriktirish
                  _sectionTitle(isDark, Icons.receipt_long_rounded, 'CHEK BIRIKTIRISH'),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => setState(() => _hasMockReceipt = !_hasMockReceipt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _hasMockReceipt
                            ? AppColors.duoGreen.withValues(alpha: 0.1)
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
                        border: Border.all(
                          color: _hasMockReceipt
                              ? AppColors.duoGreen
                              : (isDark ? Colors.white12 : AppColors.duoCardGrayShadow),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _hasMockReceipt
                                ? Icons.check_circle_rounded
                                : Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: _hasMockReceipt ? AppColors.duoGreen : (isDark ? Colors.white30 : AppColors.duoTextLight),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _hasMockReceipt ? 'CHEK BIRIKTIRILDI ✓' : 'CHEK RASMINI TANLANG',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: _hasMockReceipt
                                  ? AppColors.duoGreen
                                  : (isDark ? Colors.white54 : AppColors.duoTextLight),
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (!_hasMockReceipt) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Galereya yoki kameradan tanlang',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white30 : AppColors.duoTextLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Yuborish tugmasi
                  SizedBox(
                    width: double.infinity,
                    child: GamifiedCard(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      color: AppColors.duoGreen,
                      shadowColor: AppColors.duoGreenShadow,
                      shadowDepth: 5,
                      onTap: _isSending ? null : _submitPayment,
                      child: Center(
                        child: _isSending
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'YUBORISH',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(bool isDark, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.duoGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white70 : AppColors.duoTextLight,
            letterSpacing: 0.5,
          ),
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
