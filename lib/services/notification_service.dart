import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user notifications stream
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get unread notifications count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // Mark all notifications as read for user
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  // Create notification
  Future<void> createNotification(AppNotification notification) async {
    await _firestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  // Create homework reminder notification
  Future<void> createHomeworkReminder({
    required String userId,
    required String groupName,
    required String homeworkTitle,
    required String deadline,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Uyga vazifa eslatmasi',
      body: '$groupName guruhida "$homeworkTitle" vazifasi $deadline sanasiga qadar topshirilishi kerak',
      type: 'homework',
      createdAt: DateTime.now(),
      userId: userId,
      data: {
        'groupName': groupName,
        'homeworkTitle': homeworkTitle,
        'deadline': deadline,
      },
    );
    await createNotification(notification);
  }

  // Create lesson reminder notification
  Future<void> createLessonReminder({
    required String userId,
    required String groupName,
    required String lessonTopic,
    required String lessonTime,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Dars eslatmasi',
      body: '$groupName guruhida "$lessonTopic" darsi $lessonTime da boshlanadi',
      type: 'lesson',
      createdAt: DateTime.now(),
      userId: userId,
      data: {
        'groupName': groupName,
        'lessonTopic': lessonTopic,
        'lessonTime': lessonTime,
      },
    );
    await createNotification(notification);
  }

  // Create payment reminder notification
  Future<void> createPaymentReminder({
    required String userId,
    required String groupName,
    required String amount,
    required String dueDate,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'To\'lov eslatmasi',
      body: '$groupName guruhiga $amount so\'m to\'lov $dueDate sanasiga qadar amalga oshirilishi kerak',
      type: 'payment',
      createdAt: DateTime.now(),
      userId: userId,
      data: {
        'groupName': groupName,
        'amount': amount,
        'dueDate': dueDate,
      },
    );
    await createNotification(notification);
  }
}
