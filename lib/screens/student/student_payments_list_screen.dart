import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/student_payment_card.dart';
import 'student_payment_screen.dart';

class StudentPaymentsListScreen extends StatelessWidget {
  final String studentId;

  const StudentPaymentsListScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        title: Text(
          l.payments.toUpperCase(),
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
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentPaymentScreen(studentId: studentId),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 20, color: AppColors.duoGreen),
            label: Text(
              l.addPaymentTitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.duoGreen),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payments')
            .where('studentId', isEqualTo: studentId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.duoOrange),
            );
          }

          final docs = sortPaymentsByNewest(snap.data?.docs.toList() ?? []);

          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GamifiedCard(
                  padding: const EdgeInsets.all(32),
                  color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
                  shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 56,
                        color: isDark ? Colors.white30 : AppColors.duoTextLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.paymentHistoryEmpty,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white54 : AppColors.duoTextLight,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GamifiedCard(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        color: AppColors.duoGreen,
                        shadowColor: AppColors.duoGreenShadow,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentPaymentScreen(studentId: studentId),
                          ),
                        ),
                        child: Text(
                          l.addPaymentTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final payment = docs[index].data() as Map<String, dynamic>;
              return StudentPaymentCard(payment: payment);
            },
          );
        },
      ),
    );
  }
}
