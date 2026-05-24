import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gamified_card.dart';
import '../../services/notification_service.dart';
import '../../models/notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Xabarnomalar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
            onPressed: () async {
              await _addSampleNotifications(userProvider.uid);
            },
            tooltip: 'Namuna xabarlar qo\'shish',
          ),
          IconButton(
            icon: Icon(
              Icons.done_all_rounded,
              color: isDark ? Colors.white : AppColors.duoTextDark,
            ),
            onPressed: () async {
              await _notificationService.markAllAsRead(userProvider.uid);
            },
            tooltip: 'Barchasini o\'qildi deb belgilash',
          ),
        ],
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _notificationService.getUserNotifications(userProvider.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: EmptyState(
                emoji: '🔔',
                title: 'Hozircha xabarlar yo\'q',
                subtitle: 'Sizga yangi xabarlar kelganda bu yerda ko\'rsatiladi',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notification, bool isDark) {
    final isRead = notification.isRead ?? false;
    final type = notification.type ?? 'system';
    
    String icon;
    Color color;
    
    switch (type) {
      case 'homework':
        icon = '📝';
        color = AppColors.duoOrange;
        break;
      case 'lesson':
        icon = '📚';
        color = AppColors.duoBlue;
        break;
      case 'payment':
        icon = '💰';
        color = AppColors.duoGreen;
        break;
      default:
        icon = '🔔';
        color = AppColors.duoPurple;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GamifiedCard(
        padding: const EdgeInsets.all(16),
        color: isRead
            ? (isDark ? AppColors.duoCardGray.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.7))
            : (isDark ? AppColors.duoCardGray.withValues(alpha: 0.1) : Colors.white),
        shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
        shadowDepth: isRead ? 2 : 4,
        onTap: () async {
          if (!isRead) {
            await _notificationService.markAsRead(notification.id);
          }
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: color.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? 'Xabar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : AppColors.duoTextLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : AppColors.duoTextLight.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.duoBlue,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Hozirgina';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} daqiqa oldin';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} soat oldin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} kun oldin';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _addSampleNotifications(String userId) async {
    final notifications = [
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Uyga vazifa eslatmasi',
        body: 'A1 guruhida "Grammatika: Präteritum" vazifasi bugun topshirilishi kerak',
        type: 'homework',
        createdAt: DateTime.now(),
        isRead: false,
        userId: userId,
        data: {
          'groupName': 'A1',
          'homeworkTitle': 'Grammatika: Präteritum',
          'deadline': '2024-05-24',
        },
      ),
      AppNotification(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: 'Dars eslatmasi',
        body: 'B1 guruhida "Hören: Hörverstehen" darsi 14:00 da boshlanadi',
        type: 'lesson',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        userId: userId,
        data: {
          'groupName': 'B1',
          'lessonTopic': 'Hören: Hörverstehen',
          'lessonTime': '14:00',
        },
      ),
      AppNotification(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        title: 'To\'lov eslatmasi',
        body: 'A2 guruhiga 500,000 so\'m to\'lov 2024-05-30 sanasiga qadar amalga oshirilishi kerak',
        type: 'payment',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        userId: userId,
        data: {
          'groupName': 'A2',
          'amount': '500,000',
          'dueDate': '2024-05-30',
        },
      ),
      AppNotification(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        title: 'Yangi guruhga qo\'shildi',
        body: 'Tabriklaymiz! Siz "Deutsch für Anfänger" guruhiga muvaffaqiyatli qo\'shildingiz',
        type: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
        userId: userId,
      ),
      AppNotification(
        id: (DateTime.now().millisecondsSinceEpoch + 4).toString(),
        title: 'Uyga vazifa eslatmasi',
        body: 'B2 guruhida "Schreiben: Aufsatz" vazifasi ertaga topshirilishi kerak',
        type: 'homework',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isRead: true,
        userId: userId,
        data: {
          'groupName': 'B2',
          'homeworkTitle': 'Schreiben: Aufsatz',
          'deadline': '2024-05-19',
        },
      ),
    ];

    for (final notification in notifications) {
      await _notificationService.createNotification(notification);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Namuna xabarlar qo\'shildi!'),
          backgroundColor: AppColors.duoGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
