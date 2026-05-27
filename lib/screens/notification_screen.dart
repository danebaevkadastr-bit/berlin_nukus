import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../l10n/app_localizations.dart';
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
  void initState() {
    super.initState();
    // Don't mark as read automatically - let user mark them manually
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final userProvider = Provider.of<UserProvider>(context);
    final l = AppLocalizations.of(context);

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
          l.notificationsTitle,
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
            tooltip: l.markAllAsRead,
          ),
        ],
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _notificationService.getUserNotifications(userProvider.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    l.errorOccurred,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : AppColors.duoTextLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: EmptyState(
                emoji: '🔔',
                title: l.noNotificationsYet,
                subtitle: l.noNotificationsSubtitle,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification, isDark, l, userProvider);
            },
          );
        },
      ),
      floatingActionButton: userProvider.role == 'admin'
          ? FloatingActionButton(
              onPressed: () => _showSendNotificationDialog(context, userProvider, l),
              backgroundColor: AppColors.duoBlue,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }

  void _showSendNotificationDialog(
    BuildContext context,
    UserProvider userProvider,
    AppLocalizations l,
  ) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String? selectedUserId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l.sendMessage),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: l.titleLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bodyController,
                  decoration: InputDecoration(
                    labelText: l.messageBodyLabel,
                    border: const OutlineInputBorder(),
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
                        initialValue: selectedUserId,
                        decoration: InputDecoration(
                          labelText: l.selectUserLabel,
                          border: const OutlineInputBorder(),
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
              child: Text(l.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || bodyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.enterTitleAndMessage)),
                  );
                  return;
                }

                if (userProvider.role == 'teacher') {
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
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.messageSent)),
                    );
                  }
                } else if (userProvider.role == 'admin' && selectedUserId != null) {
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
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.messageSent)),
                    );
                  }
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(l.submit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    dynamic notification,
    bool isDark,
    AppLocalizations l,
    UserProvider userProvider,
  ) {
    final isRead = notification.isRead ?? false;
    final type = notification.type ?? 'system';
    final notificationId = notification.id;

    IconData iconData;
    Color color;

    switch (type) {
      case 'homework':
        iconData = Icons.assignment_rounded;
        color = AppColors.duoOrange;
        break;
      case 'lesson':
        iconData = Icons.school_rounded;
        color = AppColors.duoBlue;
        break;
      case 'payment':
        iconData = Icons.payments_rounded;
        color = AppColors.duoGreen;
        break;
      default:
        iconData = Icons.notifications_rounded;
        color = AppColors.duoPurple;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GamifiedCard(
        padding: const EdgeInsets.all(16),
        color: isRead
            ? (isDark 
                ? Color.alphaBlend(AppColors.duoCardGray.withValues(alpha: 0.05), const Color(0xFF131F24)) 
                : const Color(0xFFF0F0F0)) // A solid very light gray instead of transparent white for read notifications
            : (isDark 
                ? Color.alphaBlend(AppColors.duoCardGray.withValues(alpha: 0.1), const Color(0xFF131F24)) 
                : Colors.white),
        shadowColor: isDark ? Colors.black26 : AppColors.duoCardGrayShadow,
        shadowDepth: isRead ? 2 : 4,
        onTap: () async {
          if (!isRead && notificationId != null) {
            await _notificationService.markAsRead(notificationId);
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
                child: Icon(iconData, size: 24, color: color),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? l.messageFallback,
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
                    _formatDate(notification.createdAt, l),
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

  String _formatDate(DateTime? date, AppLocalizations l) {
    if (date == null) return '';
    return l.formatRelativeTime(date);
  }
}
