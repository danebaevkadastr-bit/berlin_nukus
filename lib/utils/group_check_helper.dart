// ignore_for_file: unused_element, unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_colors.dart';
import '../widgets/gamified_card.dart';

class GroupCheckHelper {
  /// Talabaning guruhga qo'shilganligini tekshiradi.
  /// Guruhga qo'shilgan bo'lsa true, qo'shilmagan bo'lsa dialog ko'rsatib false qaytaradi.
  static Future<bool> checkAndWarn(BuildContext context) async {
    // TODO: Vaqtincha guruh tekshiruvini o'chirib qo'yamiz. Keyinchalik kerak bo'lsa `return true;` qatorini olib tashlash orqali yoqish mumkin.
    return true; 
    
    /*
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('groups')
          .where('students', arrayContains: uid)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        return true; // Guruhga qo'shilgan
      }
    } catch (_) {
      // Xato bo'lsa ham dialog ko'rsatmasdan ruxsat beramiz
      return true;
    }

    // Guruhga qo'shilmagan — dialog ko'rsatish
    if (context.mounted) {
      _showNoGroupDialog(context);
    }
    return false;
    */
  }

  static void _showNoGroupDialog(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: isDark ? const Color(0xFF1E2A32) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white12 : AppColors.duoCardGrayShadow,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.duoOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group_off_rounded,
                  size: 38,
                  color: AppColors.duoOrange,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                l.noGroupTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                l.noGroupMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: isDark ? Colors.white70 : AppColors.duoTextLight,
                ),
              ),
              const SizedBox(height: 24),
              // Button
              SizedBox(
                width: double.infinity,
                child: GamifiedCard(
                  color: AppColors.duoOrange,
                  shadowColor: const Color(0xFFB35E00),
                  shadowDepth: 4,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onTap: () => Navigator.pop(ctx),
                  child: Center(
                    child: Text(
                      l.noGroupButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
