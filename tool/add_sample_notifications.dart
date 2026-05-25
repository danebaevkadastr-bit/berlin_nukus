import 'package:cloud_firestore/cloud_firestore.dart';

/// Sample notifications script
/// Run this to add sample notifications to Firebase
/// Usage: flutter run tool/add_sample_notifications.dart
void main() async {
  // Replace with actual user ID
  const userId = 'sample_user_id';
  
  final firestore = FirebaseFirestore.instance;
  
  final notifications = [
    {
      'title': 'Uyga vazifa eslatmasi',
      'body': 'A1 guruhida "Grammatika: Präteritum" vazifasi bugun topshirilishi kerak',
      'type': 'homework',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'isRead': false,
      'userId': userId,
      'data': {
        'groupName': 'A1',
        'homeworkTitle': 'Grammatika: Präteritum',
        'deadline': '2024-05-24',
      },
    },
    {
      'title': 'Dars eslatmasi',
      'body': 'B1 guruhida "Hören: Hörverstehen" darsi 14:00 da boshlanadi',
      'type': 'lesson',
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
      'isRead': false,
      'userId': userId,
      'data': {
        'groupName': 'B1',
        'lessonTopic': 'Hören: Hörverstehen',
        'lessonTime': '14:00',
      },
    },
    {
      'title': 'To\'lov eslatmasi',
      'body': 'A2 guruhiga 500,000 so\'m to\'lov 2024-05-30 sanasiga qadar amalga oshirilishi kerak',
      'type': 'payment',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      'isRead': true,
      'userId': userId,
      'data': {
        'groupName': 'A2',
        'amount': '500,000',
        'dueDate': '2024-05-30',
      },
    },
    {
      'title': 'Yangi guruhga qo\'shildi',
      'body': 'Tabriklaymiz! Siz "Deutsch für Anfänger" guruhiga muvaffaqiyatli qo\'shildingiz',
      'type': 'system',
      'createdAt': DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch,
      'isRead': true,
      'userId': userId,
    },
    {
      'title': 'Uyga vazifa eslatmasi',
      'body': 'B2 guruhida "Schreiben: Aufsatz" vazifasi ertaga topshirilishi kerak',
      'type': 'homework',
      'createdAt': DateTime.now().subtract(const Duration(days: 5)).millisecondsSinceEpoch,
      'isRead': true,
      'userId': userId,
      'data': {
        'groupName': 'B2',
        'homeworkTitle': 'Schreiben: Aufsatz',
        'deadline': '2024-05-19',
      },
    },
  ];

  // print('Adding ${notifications.length} sample notifications...');
  
  for (final notification in notifications) {
    final docRef = firestore.collection('notifications').doc();
    await docRef.set(notification);
    // print('✓ Added notification: ${notification['title']}');
  }
  
  // print('\nAll sample notifications added successfully!');
}
