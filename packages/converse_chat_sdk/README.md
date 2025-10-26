# 🗨️ Converse Flutter Chat SDK

A **modern, scalable, and modular Flutter Chat SDK** built to enable **real-time 1:1 chat experiences** with rich presence and typing indicators.  
Converse SDK provides a clean architecture, high flexibility, and easy integration with your existing backend — whether Firebase, REST APIs, or Supabase.

> **Part of the Converse Chat SDK Suite:**
> - [`converse_chat_core`](https://github.com/rbishtdev/converse_flutter_chat_sdk/tree/main/packages/converse_chat_core): Core data models, entities, and logic.
> - [`converse_chat_adapters`](https://github.com/rbishtdev/converse_flutter_chat_sdk/tree/main/packages/converse_chat_adapters): Adapter layer to connect backend and SDK.
> - [`converse_flutter_chat_sdk`](https://github.com/rbishtdev/converse_flutter_chat_sdk): The main SDK that brings everything together for Flutter apps.

---

## 🚀 Features

### ✅ **Current Functionality**
- 💬 **1:1 Real-time Chat**
- 👤 **User Presence:** Online / Offline status
- 🕒 **Last Seen Tracking**
- ✍️ **Typing Indicator Support**
- ⚙️ **Reactive Stream-based Architecture**
- 🔄 **Offline-safe Message Sync**
- 🧱 **Clean Modular Layers (Core → Adapter → SDK)**

### 🧭 **Planned Enhancements**
- 👥 **Group Chat Support**
- 📎 **Attachment Support** (Images, Files, Videos) for both **1:1** and **Group Chats**
- 🌐 **Backend Adapters** for:
    - REST APIs
    - Supabase Realtime
- 🧩 ** Chat UI SDK With Custom Theming and Message Components**

---

## 📦 Installation

Add the package to your project:

```yaml
dependencies:
  converse_flutter_chat_sdk: ^1.0.0
```

Then fetch the dependencies:

```bash
flutter pub get
```

---

# 💬 Converse Flutter Chat SDK — Example: ChatScreen

This example demonstrates how to build a **1:1 real-time chat screen** using the **Converse Chat SDK**.  
It includes chat creation, presence tracking, typing indicators, last-seen updates, and message streaming.

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:converse_chat_sdk/converse_chat_sdk.dart';

/// 🧩 ChatScreen
/// 
/// A full-featured example demonstrating:
/// - Chat initialization
/// - Real-time message streaming
/// - Presence (online/offline & last seen)
/// - Typing indicators
/// - Sending messages
/// 
/// This screen can be copied directly into your Flutter app.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.peerUserId,
  });

  /// The currently logged-in user ID
  final String currentUserId;

  /// The user you're chatting with
  final String peerUserId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  // ---------------------------------------------------------------------------
  // 🧠 SDK CLIENT AND STATE
  // ---------------------------------------------------------------------------

  /// Converse Chat SDK client instance
  late ConverseChatClient _converseChatClient;

  /// Chat ID generated or fetched from the SDK
  late String _chatId;

  /// Local message list for rendering
  final List<Message> _messages = [];

  /// Input and scrolling controllers
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Stream subscriptions for messages, presence, typing, etc.
  StreamSubscription? _messageStreamSubscription;
  StreamSubscription? _presenceStreamSubscription;
  StreamSubscription? _lastSeenStreamSubscription;
  StreamSubscription? _typingStreamSubscription;

  /// Local UI states
  bool _isLoading = true;
  bool _isOtherUserOnline = false;
  bool _isTyping = false;
  bool _isOtherUserTyping = false;
  Timer? _typingTimer;
  int? _lastSeenTime;

  /// Shortcuts for current and peer users
  String get _userA => widget.currentUserId;
  String get _userB => widget.peerUserId;

  // ---------------------------------------------------------------------------
  // 🚀 LIFECYCLE
  // ---------------------------------------------------------------------------

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

  /// Handles online status based on app lifecycle
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final isActive = state == AppLifecycleState.resumed;
    await _converseChatClient.setOnlineStatus(_userA, isActive);
  }

  // ---------------------------------------------------------------------------
  // 🔹 INITIALIZATION
  // ---------------------------------------------------------------------------

  /// Initializes the SDK and sets up chat listeners
  Future<void> _initializeChat() async {
    try {
      // Initialize Converse Chat SDK for the logged-in user
      _converseChatClient = await ConverseChatClient.initialize(currentUserId: _userA);
      await _converseChatClient.setOnlineStatus(_userA, true);

      // Create or join a chat between current and peer user
      final chatResult = await _converseChatClient.createOrJoinChat(_userA, _userB);

      chatResult.match(
        (failure) => debugPrint('❌ Failed to create chat: ${failure.message}'),
        (chatId) async {
          _chatId = chatId;

          // Start listening to various real-time updates
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

  // ---------------------------------------------------------------------------
  // 👀 LISTENERS (MESSAGES, PRESENCE, TYPING, LAST SEEN)
  // ---------------------------------------------------------------------------

  /// Watches for new messages in the chat
  void _listenToMessages() {
    _messageStreamSubscription = _converseChatClient.messages.watchMessages(_chatId).listen((result) {
      if (!mounted) return;

      result.match(
        (failure) => debugPrint('❌ Message stream error: ${failure.message}'),
        (messages) => setState(() {
          _messages..clear()..addAll(messages);
        }),
      );

      // Auto-scroll to bottom after new messages
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  /// Listens to online/offline presence updates
  void _listenToPresence() {
    _presenceStreamSubscription = _converseChatClient.watchUserPresence(_userB).listen((result) {
      result.match(
        (failure) => debugPrint('❌ Presence error: ${failure.message}'),
        (isOnline) => setState(() => _isOtherUserOnline = isOnline),
      );
    });
  }

  /// Watches the last seen timestamp of the peer user
  void _listenToLastSeen() {
    _lastSeenStreamSubscription = _converseChatClient.watchLastSeen(_userB).listen((result) {
      result.match(
        (failure) => debugPrint('❌ Last seen error: ${failure.message}'),
        (lastSeen) => setState(() => _lastSeenTime = lastSeen),
      );
    });
  }

  /// Monitors typing indicators in the chat
  void _listenToTyping() {
    _typingStreamSubscription = _converseChatClient.watchTypingUsers(_chatId).listen((result) {
      result.match(
        (failure) => debugPrint('❌ Typing error: ${failure.message}'),
        (typing) => setState(() => _isOtherUserTyping = typing[_userB] == true),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // 💬 ACTIONS (SENDING MESSAGES, TYPING STATE)
  // ---------------------------------------------------------------------------

  /// Sends a text message using the SDK
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

  /// Updates typing state (true while user is typing)
  void _onTextChanged(String value) {
    const typingDelay = Duration(seconds: 1);

    if (!_isTyping) {
      setState(() => _isTyping = true);
      _converseChatClient.setTypingState(_chatId, _userA, true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(typingDelay, () {
      setState(() => _isTyping = false);
      _converseChatClient.setTypingState(_chatId, _userA, false);
    });
  }

  // ---------------------------------------------------------------------------
  // 🧹 CLEANUP
  // ---------------------------------------------------------------------------

  /// Cancels streams, timers, and disposes resources
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

  // ---------------------------------------------------------------------------
  // 🧱 UI (APPBAR, MESSAGE LIST, INPUT BAR)
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 2,
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
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                _isOtherUserTyping
                    ? const Text('Typing...', style: TextStyle(color: Colors.lightGreenAccent, fontSize: 13))
                    : Text(
                        _isOtherUserOnline
                            ? 'Online'
                            : (_lastSeenTime != null)
                                ? formatLastSeenWhatsAppStyle(_lastSeenTime!)
                                : '',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
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
                    'Powered by Converse Flutter Chat SDK 🚀',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
    );
  }

  /// Builds the scrollable list of chat messages
  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('No messages yet', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(10),
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
                  bottomLeft: isMe ? const Radius.circular(14) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg.text ?? '', style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(formatTimestamp(msg.createdAt), style: TextStyle(color: Colors.white70, fontSize: 10)),
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

  /// Builds the text input and send button
  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, -2))],
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  // ---------------------------------------------------------------------------
  // 🧩 HELPERS
  // ---------------------------------------------------------------------------

  /// Scrolls chat to the bottom
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

  /// Formats message timestamps to readable time
  String formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('hh:mm a').format(dateTime.toLocal());
  }

  /// Builds message delivery/read status icons
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

/// Formats "last seen" text similar to WhatsApp
String formatLastSeenWhatsAppStyle(int timestamp) {
  final now = DateTime.now();
  final lastSeen = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final diff = now.difference(lastSeen);

  final timeFormat = DateFormat('hh:mm a');
  final dateFormat = DateFormat('d MMM yyyy');
  final weekdayFormat = DateFormat('EEEE');

  if (diff.inSeconds < 60) return 'Last seen just now';
  if (diff.inMinutes < 60) return 'Last seen ${diff.inMinutes} min ago';
  if (diff.inHours < 24 && lastSeen.day == now.day) return 'Last seen today at ${timeFormat.format(lastSeen)}';
  if (diff.inDays == 1) return 'Last seen yesterday at ${timeFormat.format(lastSeen)}';
  if (diff.inDays < 7) return 'Last seen ${weekdayFormat.format(lastSeen)} at ${timeFormat.format(lastSeen)}';
  return 'Last seen on ${dateFormat.format(lastSeen)}';
}
```

---

## 🧱 Architecture Overview

```
┌────────────────────────────┐
│ converse_flutter_chat_sdk  │  ← Main Flutter SDK
└────────────┬───────────────┘
             │
┌────────────▼───────────────┐
│ converse_chat_adapters     │  ← Adapters (Firebase, REST, Supabase)
└────────────┬───────────────┘
             │
┌────────────▼───────────────┐
│ converse_chat_core         │  ← Core logic, models, and entities
└────────────────────────────┘
```

- **Core Layer:** Pure Dart logic (entities, models, and utils)
- **Adapter Layer:** Connects SDK with backend sources
- **SDK Layer:** Provides the high-level API for your Flutter app

---

## 🧩 Extending the SDK

Implement your own backend adapter easily:

```dart
class RestChatAdapter extends ChatAdapter {
  @override
  Future<void> sendMessage(ChatMessage message) async {
    await http.post(
      Uri.parse("https://api.example.com/messages"),
      body: message.toJson(),
    );
  }

  @override
  Stream<ChatMessage> messageStream(String roomId) {
    // Connect to a WebSocket or SSE
  }
}
```

Initialize with your custom adapter:

```dart
final chatSDK = ConverseChatSDK.initialize(
  adapter: RestChatAdapter(),
);
```

---

## 🧠 Core Concepts

| Concept | Description |
|----------|-------------|
| **ChatMessage** | Represents a chat message (text, media, metadata) |
| **ChatRoom** | A conversation between one or more users |
| **ChatUser** | Represents a user with presence and last seen info |
| **ChatAdapter** | Abstraction layer for backend integrations |
| **ChatConfig** | Configuration for SDK initialization and behavior |

---

## 🧰 Example Folder Structure

```
lib/
 ├── converse_flutter_chat_sdk.dart
 ├── src/
 │   ├── core/
 │   ├── adapters/
 │   ├── services/
 │   ├── models/
 │   └── ui/
example/
 └── main.dart
```

---

## 🧪 Example App

An example Flutter app is included demonstrating:
- Realtime 1:1 chat
- User presence updates
- Typing indicators
- Firebase and REST example implementations

Run with:

```bash
flutter run --target=example/lib/main.dart
```

---

## 🗺️ Roadmap

| Feature                               | Status |
|---------------------------------------|--------|
| 1:1 Chat                              | ✅ Done |
| User Presence                         | ✅ Done |
| Typing Indicator                      | ✅ Done |
| Full Example App                      | ✅ Done |
| Group Chat                            | 🔜 Planned |
| Attachments (Media & Files)           | 🔜 Planned |
| REST / Supabase Adapters              | 🔜 Planned |
| Full Example App with REST & Supabase | 🔜 Planned |

---

## 📖 Documentation

- [SDK Documentation →](https://github.com/rbishtdev/converse_flutter_chat_sdk/wiki)
- [Core Package →](https://github.com/rbishtdev/converse_flutter_chat_sdk/tree/main/packages/converse_chat_core)
- [Adapter Package →](https://github.com/rbishtdev/converse_flutter_chat_sdk/tree/main/packages/converse_chat_adapters)

---

## 🧑‍💻 Contributing

We love contributions!
1. Fork the repo
2. Create a feature branch
3. Commit and push changes
4. Submit a pull request 🚀

---

## 🧾 License

Licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for more details.

---

## 🏷️ Maintainer

**Rajendra Bisht**  
[GitHub Profile →](https://github.com/rbishtdev)
