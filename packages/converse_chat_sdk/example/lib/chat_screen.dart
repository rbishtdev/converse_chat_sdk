import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:converse_chat_sdk/converse_chat_sdk.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.peerUserId,
  });

  final String currentUserId;
  final String peerUserId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  // SDK
  late ConverseChatClient _converseChatClient;
  late String _chatId;

  // State
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  StreamSubscription? _messageStreamSubscription;
  StreamSubscription? _presenceStreamSubscription;
  StreamSubscription? _lastSeenStreamSubscription;
  StreamSubscription? _typingStreamSubscription;

  bool _isLoading = true;
  bool _isOtherUserOnline = false;
  bool _isTyping = false;
  bool _isOtherUserTyping = false;
  Timer? _typingTimer;
  int? _lastSeenTime;

  String get _userA => widget.currentUserId;
  String get _userB => widget.peerUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeChat();
  }

  @override
  void dispose() {
    _cleanupResources();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final isActive = state == AppLifecycleState.resumed;
    await _converseChatClient.setOnlineStatus(_userA, isActive);
  }

  // -----------------------------
  // 🔹 Initialization
  // -----------------------------
  Future<void> _initializeChat() async {
    try {
      _converseChatClient =
      await ConverseChatClient.initialize(currentUserId: _userA);
      await _converseChatClient.setOnlineStatus(_userA, true);

      final chatResult = await _converseChatClient.ensureChatExists(_userA, _userB);
      chatResult.match(
            (failure) => debugPrint('❌ Failed to create chat: ${failure.message}'),
            (chatId) async {
          _chatId = chatId;
          _listenToMessages();
          _listenToPresence();
          _listenToTyping();
          _listenToLastSeen();

          setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      debugPrint('🔥 Chat initialization error: $e');
      setState(() => _isLoading = false);
    }
  }

  // -----------------------------
  // 🔹 Listeners
  // -----------------------------
  void _listenToMessages() {
    _messageStreamSubscription = _converseChatClient
        .messages
        .watchMessages(_chatId)
        .listen((result) {
      if (!mounted) return; // Prevent setState if widget is disposed

      result.match(
            (failure) => debugPrint('❌ Stream error: ${failure.message}'),
            (messages) => setState(() {
          _messages
            ..clear()
            ..addAll(messages);
        }),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  void _listenToPresence() {
    _presenceStreamSubscription = _converseChatClient.watchUserPresence(_userB).listen((result) {
      result.match(
            (failure) => debugPrint('❌ Presence error: ${failure.message}'),
            (isOnline) {
          if (mounted) {
            setState(() {
              _isOtherUserOnline = isOnline;
            });
          }
        },
      );
    });
  }

  void _listenToLastSeen() {
    _lastSeenStreamSubscription = _converseChatClient.watchLastSeen(_userB).listen((result) {
      result.match(
            (failure) => debugPrint('❌ Last seen error: ${failure.message}'),
            (lastSeen) {
          if (mounted && lastSeen != null) {
            setState(() {
              _lastSeenTime = lastSeen;
            });
          }
        },
      );
    });
  }


  void _listenToTyping() {
    _typingStreamSubscription = _converseChatClient.watchTypingUsers(_chatId).listen((result) {
      result.match(
            (failure) => debugPrint('❌ Typing error: ${failure.message}'),
            (typing) {
          final isOtherTyping = typing[_userB] == true;
          if (mounted) setState(() => _isOtherUserTyping = isOtherTyping);
        },
      );
    });
  }

  // -----------------------------
  // 🔹 Actions
  // -----------------------------
  void _onTextChanged(String value) {
    const typingDelay = Duration(seconds: 1);

    if (!_isTyping) {
      setState(() => _isTyping = true);
      _converseChatClient.setTypingState(_chatId, _userA, true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(typingDelay, () {
      if (_isTyping) {
        setState(() => _isTyping = false);
        _converseChatClient.setTypingState(_chatId, _userA, false);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    try {
      _converseChatClient.messages.sendText(
        chatId: _chatId,
        senderId: _userA,
        text: text,
      );
      _textController.clear();
      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Failed to send message: $e');
    }
  }

  Future<void> _cleanupResources() async {
    await _converseChatClient.setOnlineStatus(_userA, false);
    await _messageStreamSubscription?.cancel();
    await _presenceStreamSubscription?.cancel();
    await _lastSeenStreamSubscription?.cancel();
    await _typingStreamSubscription?.cancel();
    _converseChatClient.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
  }

  // -----------------------------
  // 🔹 UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.indigo,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.indigo),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userB,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                _isOtherUserTyping
                    ? const Text(
                  'Typing...',
                  style: TextStyle(
                    color: Colors.lightGreenAccent,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                )
                    : Text(
                  _isOtherUserOnline
                      ? 'Online'
                      : (_lastSeenTime != null)
                      ? formatLastSeenWhatsAppStyle(_lastSeenTime!)
                      : '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : Column(
        children: [
          _buildMessageList(),
          _buildMessageInput(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Powered by Converse Flutter SDK Chat 🚀\nBuilt on Firebase Realtime Database & Cloud Firestore 🔥',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No messages yet',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final msg = _messages[index];
          final isMe = msg.senderId == _userA;

          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.indigo[400] : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft:
                  isMe ? const Radius.circular(14) : const Radius.circular(4),
                  bottomRight:
                  isMe ? const Radius.circular(4) : const Radius.circular(14),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.text ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTimestamp(msg.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (isMe) _buildStatusIcon(msg.status),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onChanged: _onTextChanged,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.indigo,
              radius: 22,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Helpers
  String formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('hh:mm a').format(dateTime.toLocal());
  }

  Widget _buildStatusIcon(MessageStatus status) {
    const size = 12.0;
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: size, color: Colors.grey);
      case MessageStatus.sent:
        return const Icon(Icons.done, size: size, color: Colors.grey);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: size, color: Colors.grey);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: size, color: Colors.blue);
      case MessageStatus.failed:
        return const Icon(Icons.error_outline, size: size, color: Colors.red);
    }
  }
}


String formatLastSeenWhatsAppStyle(int timestamp) {
  final now = DateTime.now();
  final lastSeen = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final diff = now.difference(lastSeen);

  final timeFormat = DateFormat('hh:mm a'); // 12-hour clock (3:45 PM)
  final dateFormat = DateFormat('d MMM yyyy'); // e.g., 2 Feb 2025
  final weekdayFormat = DateFormat('EEEE'); // Monday, Tuesday, etc.

  if (diff.inSeconds < 60) {
    return 'Last seen just now';
  } else if (diff.inMinutes < 60) {
    return 'Last seen ${diff.inMinutes} min ago';
  } else if (diff.inHours < 24 && lastSeen.day == now.day) {
    return 'Last seen today at ${timeFormat.format(lastSeen)}';
  } else if (diff.inDays == 1 ||
      (now.day - lastSeen.day == 1 && now.month == lastSeen.month)) {
    return 'Last seen yesterday at ${timeFormat.format(lastSeen)}';
  } else if (diff.inDays < 7) {
    return 'Last seen ${weekdayFormat.format(lastSeen)} at ${timeFormat.format(lastSeen)}';
  } else {
    return 'Last seen on ${dateFormat.format(lastSeen)}';
  }
}

