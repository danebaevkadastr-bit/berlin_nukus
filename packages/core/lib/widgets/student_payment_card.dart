import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/theme_manager.dart';
import '../l10n/app_localizations.dart';
import 'gamified_card.dart';

class StudentPaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;

  const StudentPaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = ThemeManager.isDark;
    final status = payment['status'] ?? 'pending';
    final periodStart = (payment['periodStart'] as Timestamp?)?.toDate();
    final periodEnd = (payment['periodEnd'] as Timestamp?)?.toDate();
    final note = payment['note'] ?? '';
    final adminNote = payment['adminNote'] ?? '';
    final type = payment['type'] ?? 'card';

    Color statusColor;
    String statusText;
    IconData statusIcon;
    switch (status) {
      case 'accepted':
        statusColor = AppColors.duoGreen;
        statusText = l.paymentAcceptedMsg;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = AppColors.duoRed;
        statusText = l.paymentRejectedMsg;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.duoOrange;
        statusText = l.paymentPending;
        statusIcon = Icons.pending_rounded;
    }

    String periodText = '';
    if (periodStart != null && periodEnd != null) {
      periodText =
          '${periodStart.day}.${_pad(periodStart.month)}.${periodStart.year} – ${periodEnd.day}.${_pad(periodEnd.month)}.${periodEnd.year}';
    }

    return GamifiedCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white,
      shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: statusColor.withValues(alpha: 0.15),
            ),
            child: Icon(statusIcon, color: statusColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  periodText.isNotEmpty ? periodText : l.periodUnknown,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    note,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : AppColors.duoTextLight,
                    ),
                  ),
                ],
                if (adminNote.isNotEmpty && status != 'pending') ...[
                  const SizedBox(height: 3),
                  Text(
                    '${l.adminLabel}: $adminNote',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  type == 'cash' ? l.cashLabel : l.cardLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white38 : AppColors.duoTextLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: statusColor.withValues(alpha: 0.12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _pad(int v) => v.toString().padLeft(2, '0');
}

/// To'lovlarni `createdAt` bo'yicha yangidan eskiga tartiblaydi.
List<QueryDocumentSnapshot> sortPaymentsByNewest(List<QueryDocumentSnapshot> docs) {
  final sorted = docs.toList();
  sorted.sort((a, b) {
    final ta = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
    final tb = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
    if (ta == null && tb == null) return 0;
    if (ta == null) return 1;
    if (tb == null) return -1;
    return tb.compareTo(ta);
  });
  return sorted;
}
