class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // 'homework', 'lesson', 'payment', 'system'
  final DateTime createdAt;
  final bool isRead;
  final String? userId;
  final String? groupId;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.userId,
    this.groupId,
    this.data,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'system',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      userId: map['userId'],
      groupId: map['groupId'],
      data: map['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
      if (userId != null) 'userId': userId,
      if (groupId != null) 'groupId': groupId,
      if (data != null) 'data': data,
    };
  }
}
