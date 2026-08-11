import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/gamified_card.dart';
import '../../widgets/user_avatar.dart';
import '../../utils/app_colors.dart';
import '../../utils/theme_manager.dart';
import '../../l10n/app_localizations.dart';

class StudentChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const StudentChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<StudentChatScreen> createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _editingMessageId;
  String? _replyToMessageId;
  Map<String, dynamic>? _replyToMessageData;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      if (_editingMessageId != null) {
        // Edit existing message
        await _firestore
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .doc(_editingMessageId)
            .update({
          'text': text,
          'edited': true,
          'editedAt': FieldValue.serverTimestamp(),
        });
        
        setState(() {
          _editingMessageId = null;
        });
      } else {
        // Send new message
        final messageData = {
          'text': text,
          'senderId': user.uid,
          'senderName': userProvider.name,
          'senderAvatar': userProvider.avatarUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'text',
          'edited': false,
        };

        // Add reply reference if replying
        if (_replyToMessageId != null && _replyToMessageData != null) {
          messageData['replyTo'] = {
            'messageId': _replyToMessageId,
            'text': _replyToMessageData!['text'],
            'senderName': _replyToMessageData!['senderName'],
          };
        }

        await _firestore
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .add(messageData);
        
        setState(() {
          _replyToMessageId = null;
          _replyToMessageData = null;
        });
      }

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  void _cancelEdit() {
    setState(() {
      _editingMessageId = null;
      _messageController.clear();
    });
  }

  void _cancelReply() {
    setState(() {
      _replyToMessageId = null;
      _replyToMessageData = null;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.isDark;
    final userProvider = Provider.of<UserProvider>(context);
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E2A32) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () => _showGroupMembers(context, isDark, l),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.duoGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.group_rounded,
                    size: 20,
                    color: AppColors.duoGreen,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.groupName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.duoTextDark,
                      ),
                    ),
                    Text(
                      l.groupChat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : AppColors.duoTextLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.info_outline_rounded,
                color: isDark ? Colors.white54 : AppColors.duoTextLight,
                size: 18,
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 64,
                          color: isDark ? Colors.white54 : AppColors.duoTextLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.noMessagesYet,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : AppColors.duoTextLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.sendFirstMessage,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white38 : AppColors.duoTextLight.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final data = message.data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == userProvider.uid;
                    final senderName = data['senderName'] ?? l.unknown;
                    final senderAvatar = data['senderAvatar'] ?? '';
                    final text = data['text'] ?? '';
                    final timestamp = data['timestamp'] as Timestamp?;
                    final edited = data['edited'] ?? false;
                    final replyTo = data['replyTo'] as Map<String, dynamic>?;

                    return _buildMessageBubble(
                      messageId: message.id,
                      isMe: isMe,
                      senderName: senderName,
                      senderAvatar: senderAvatar,
                      text: text,
                      timestamp: timestamp,
                      edited: edited,
                      replyTo: replyTo,
                      isDark: isDark,
                      l: l,
                      userProvider: userProvider,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(isDark, l),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String messageId,
    required bool isMe,
    required String senderName,
    required String senderAvatar,
    required String text,
    required Timestamp? timestamp,
    required bool edited,
    required Map<String, dynamic>? replyTo,
    required bool isDark,
    required AppLocalizations l,
    required UserProvider userProvider,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Row(
              children: [
                UserAvatar(
                  imageUrl: senderAvatar,
                  size: 28,
                  fallbackEmoji: '👤',
                  backgroundColor: AppColors.duoGreen.withValues(alpha: 0.15),
                  borderRadius: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  senderName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : AppColors.duoTextLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: GestureDetector(
                  onLongPress: () => _showMessageOptions(
                    context,
                    messageId,
                    text,
                    isMe,
                    isDark,
                    l,
                    senderName: senderName,
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.duoBlue
                          : (isDark ? const Color(0xFF1E2A32) : Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isMe ? 20 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reply preview
                        if (replyTo != null) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: (isMe ? Colors.white : AppColors.duoBlue)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                left: BorderSide(
                                  color: isMe ? Colors.white : AppColors.duoBlue,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  replyTo['senderName'] ?? l.unknown,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isMe
                                        ? Colors.white
                                        : (isDark ? Colors.white : AppColors.duoTextDark),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  replyTo['text'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isMe
                                        ? Colors.white70
                                        : (isDark ? Colors.white70 : AppColors.duoTextLight),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                        // Message text
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isMe
                                ? Colors.white
                                : (isDark ? Colors.white : AppColors.duoTextDark),
                          ),
                        ),
                        // Edited indicator
                        if (edited) ...[
                          const SizedBox(height: 4),
                          Text(
                            l.edited,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: isMe
                                  ? Colors.white70
                                  : (isDark ? Colors.white54 : AppColors.duoTextLight),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(timestamp, l),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : AppColors.duoTextLight.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(
    BuildContext context,
    String messageId,
    String text,
    bool isMe,
    bool isDark,
    AppLocalizations l, {
    required String senderName,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2A32) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Reply option
              ListTile(
                leading: Icon(
                  Icons.reply_rounded,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
                title: Text(
                  l.reply,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _replyToMessageId = messageId;
                    _replyToMessageData = {
                      'text': text,
                      'senderName': senderName,
                    };
                  });
                  FocusScope.of(context).requestFocus(FocusNode());
                },
              ),
              // Copy option
              ListTile(
                leading: Icon(
                  Icons.copy_rounded,
                  color: isDark ? Colors.white : AppColors.duoTextDark,
                ),
                title: Text(
                  l.copy,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.duoTextDark,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.copiedToClipboard),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              // Edit option (only for own messages)
              if (isMe) ...[
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: AppColors.duoBlue),
                  title: Text(
                    l.edit,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.duoBlue,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _editingMessageId = messageId;
                      _messageController.text = text;
                    });
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
                // Delete option (only for own messages)
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: AppColors.duoRed),
                  title: Text(
                    l.delete,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.duoRed,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(context, messageId, isDark, l);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String messageId,
    bool isDark,
    AppLocalizations l,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2A32) : Colors.white,
        title: Text(
          l.deleteMessage,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.duoTextDark,
          ),
        ),
        content: Text(
          l.deleteMessageConfirm,
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.duoTextLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.duoRed),
            child: Text(l.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestore
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .doc(messageId)
            .delete();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.messageDeleted),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.errorOccurred),
              backgroundColor: AppColors.duoRed,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildMessageInput(bool isDark, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A32) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit/Reply indicator
          if (_editingMessageId != null || _replyToMessageId != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: (_editingMessageId != null ? AppColors.duoBlue : AppColors.duoGreen)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: _editingMessageId != null ? AppColors.duoBlue : AppColors.duoGreen,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _editingMessageId != null ? Icons.edit_rounded : Icons.reply_rounded,
                    size: 20,
                    color: _editingMessageId != null ? AppColors.duoBlue : AppColors.duoGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editingMessageId != null ? l.editingMessage : l.replyingTo,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _editingMessageId != null ? AppColors.duoBlue : AppColors.duoGreen,
                          ),
                        ),
                        if (_replyToMessageData != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _replyToMessageData!['senderName'] ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : AppColors.duoTextLight,
                            ),
                          ),
                          Text(
                            _replyToMessageData!['text'] ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white54 : AppColors.duoTextLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: _editingMessageId != null ? _cancelEdit : _cancelReply,
                    color: isDark ? Colors.white54 : AppColors.duoTextLight,
                  ),
                ],
              ),
            ),
          ],
          // Input row
          Row(
            children: [
              Expanded(
                child: GamifiedCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: isDark ? const Color(0xFF131F24) : AppColors.duoBackground,
                  shadowColor: Colors.transparent,
                  shadowDepth: 0,
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                    decoration: InputDecoration(
                      hintText: l.writeMessageHint,
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white38 : AppColors.duoTextLight.withValues(alpha: 0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _editingMessageId != null ? AppColors.duoBlue : AppColors.duoGreen,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    _editingMessageId != null ? Icons.check_rounded : Icons.send_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(Timestamp? timestamp, AppLocalizations l) {
    if (timestamp == null) return '';
    return l.formatChatTime(timestamp.toDate());
  }

  Future<void> _showGroupMembers(BuildContext context, bool isDark, AppLocalizations l) async {
    final groupDoc = await _firestore.collection('groups').doc(widget.groupId).get();
    if (!groupDoc.exists) return;

    final groupData = groupDoc.data();
    final studentIds = List<String>.from(groupData?['students'] ?? []);
    final teacherId = groupData?['teacherId'] as String?;

    if (studentIds.isEmpty && teacherId == null) return;

    final users = <Map<String, dynamic>>[];

    // Get teacher
    if (teacherId != null) {
      final teacherDoc = await _firestore.collection('users').doc(teacherId).get();
      if (teacherDoc.exists) {
        final teacherData = teacherDoc.data();
        teacherData?['id'] = teacherDoc.id;
        teacherData?['role'] = 'teacher';
        users.add(teacherData!);
      }
    }

    // Get students
    for (final studentId in studentIds) {
      final studentDoc = await _firestore.collection('users').doc(studentId).get();
      if (studentDoc.exists) {
        final studentData = studentDoc.data();
        studentData?['id'] = studentDoc.id;
        studentData?['role'] = 'student';
        users.add(studentData!);
      }
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2A32) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.groupMembersTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.duoTextDark,
                    ),
                  ),
                  Text(
                    l.peopleCount(users.length),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : AppColors.duoTextLight,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final name = user['fullName'] ?? user['name'] ?? l.unknown;
                  final avatarUrl = user['avatarUrl'] ?? '';
                  final role = user['role'] ?? 'student';
                  final isTeacher = role == 'teacher';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        UserAvatar(
                          imageUrl: avatarUrl,
                          size: 48,
                          fallbackEmoji: isTeacher ? '👨‍🏫' : '👤',
                          backgroundColor: isTeacher
                              ? AppColors.duoPurple.withValues(alpha: 0.15)
                              : AppColors.duoGreen.withValues(alpha: 0.15),
                          borderRadius: 16,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : AppColors.duoTextDark,
                                    ),
                                  ),
                                  if (isTeacher) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.duoPurple,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        l.teacherBadge,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isTeacher ? l.groupTeacherRole : l.student,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white54 : AppColors.duoTextLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
