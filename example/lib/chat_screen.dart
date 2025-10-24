import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:converse_chat_sdk/converse_chat_sdk.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.userA,
    required this.userB,
  });

  final String userA;
  final String userB;

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

  bool _isLoading = true;
  bool _isOtherUserOnline = false;
  bool _isTyping = false;
  bool _isOtherUserTyping = false;
  Timer? _typingTimer;

  String get _userA => widget.userA;
  String get _userB => widget.userB;

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
    _converseChatClient.messages.watchMessages(_chatId).listen((result) {
      result.match(
            (failure) => debugPrint('❌ Stream error: ${failure.message}'),
            (messages) => setState(() {
          _messages
            ..clear()
            ..addAll(messages);
        }),
      );
    });
  }

  void _listenToPresence() {
    _converseChatClient.watchUserPresence(_userB).listen((result) {
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


  void _listenToTyping() {
    _converseChatClient.watchTypingUsers(_chatId).listen((result) {
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
    } catch (e) {
      debugPrint('❌ Failed to send message: $e');
    }
  }

  Future<void> _cleanupResources() async {
    await _converseChatClient.setOnlineStatus(_userA, false);
    _converseChatClient.dispose();
    _textController.dispose();
    _typingTimer?.cancel();
  }

  // -----------------------------
  // 🔹 UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_userB),
            _isOtherUserTyping ? Text(_isOtherUserOnline ? 'Typing...' : '', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)) : Text(_isOtherUserOnline ? 'Online' : '', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildMessageList(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return const Expanded(
        child: Center(child: Text('No messages yet')),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final msg = _messages[index];
          final isMe = msg.senderId == _userA;

          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.deepPurple.shade100
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg.text ?? '', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTimestamp(msg.createdAt),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onChanged: _onTextChanged,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
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
