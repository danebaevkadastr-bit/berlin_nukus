import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gamified_card.dart';
import '../../services/notification_service.dart';
import '../../models/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            return const Center(
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
      floatingActionButton: (userProvider.role == 'admin' || userProvider.role == 'teacher')
          ? FloatingActionButton(
              onPressed: () => _showSendNotificationDialog(context, userProvider),
              backgroundColor: AppColors.duoBlue,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }

  void _showSendNotificationDialog(BuildContext context, UserProvider userProvider) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String? selectedUserId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Xabar yuborish'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Sarlavha',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Xabar matni',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                if (userProvider.role == 'admin')
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role', whereIn: ['student', 'teacher'])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final users = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        value: selectedUserId,
                        decoration: const InputDecoration(
                          labelText: 'Foydalanuvchini tanlang',
                          border: OutlineInputBorder(),
                        ),
                        items: users.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text('${data['fullName'] ?? ''} (${data['role']})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUserId = value;
                          });
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || bodyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sarlavha va xabar matnini kiriting')),
                  );
                  return;
                }

                if (userProvider.role == 'teacher') {
                  // Teacher sends to their students
                  final groupsSnapshot = await FirebaseFirestore.instance
                      .collection('groups')
                      .where('teacherId', isEqualTo: userProvider.uid)
                      .get();

                  for (final groupDoc in groupsSnapshot.docs) {
                    final groupData = groupDoc.data();
                    final studentIds = groupData['studentIds'] as List<dynamic>?;

                    if (studentIds != null) {
                      for (final studentId in studentIds) {
                        await _notificationService.createNotification(
                          AppNotification(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleController.text,
                            body: bodyController.text,
                            type: 'system',
                            createdAt: DateTime.now(),
                            userId: studentId as String,
                          ),
                        );
                      }
                    }
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xabar yuborildi')),
                  );
                } else if (userProvider.role == 'admin' && selectedUserId != null) {
                  // Admin sends to specific user
                  await _notificationService.createNotification(
                    AppNotification(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      body: bodyController.text,
                      type: 'system',
                      createdAt: DateTime.now(),
                      userId: selectedUserId!,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xabar yuborildi')),
                  );
                }

                Navigator.pop(context);
              },
              child: const Text('Yuborish'),
            ),
          ],
        ),
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
              const SizedBox(
                width: 10,
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.duoBlue,
                  ),
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
}
