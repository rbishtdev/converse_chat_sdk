import 'dart:async';
import 'package:flutter/material.dart'; // Needed for Flutter entrypoint
import 'package:firebase_core/firebase_core.dart';
import 'package:converse_chat_core/converse_chat_core.dart';
import 'package:converse_chat_adapters/converse_chat_adapters.dart';

/// Converse Firebase Chat Adapter Example
/// --------------------------------------
/// Demonstrates how to use the adapter directly with Firebase Firestore,
/// Storage, and Realtime Database — without UI widgets.
///
/// Run with:
///   flutter run -d chrome
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'fake-api-key',
      appId: 'fake-app-id',
      messagingSenderId: 'fake-sender-id',
      projectId: 'your-firebase-project-id',
      databaseURL: 'https://your-firebase-project-id.firebaseio.com',
      storageBucket: 'your-firebase-project-id.appspot.com',
    ),
  );

  runApp(const FirebaseAdapterExample());
}

class FirebaseAdapterExample extends StatefulWidget {
  const FirebaseAdapterExample({super.key});

  @override
  State<FirebaseAdapterExample> createState() => _FirebaseAdapterExampleState();
}

class _FirebaseAdapterExampleState extends State<FirebaseAdapterExample> {
  late FirebaseChatAdapter adapter;
  late StreamSubscription _sub;
  String log = '';
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    log += '🚀 Firebase Chat Adapter Example Started\n';

    // 1️⃣ Create adapter repositories
    adapter = await FirebaseChatAdapter.createDefault();

    // 2️⃣ Ensure chat exists between two users
    final chatResult = await adapter.chat.createOrJoinChat('user_a', 'user_b');
    final chatId = chatResult.getOrElse((_) => 'default_chat');
    log += '💬 Chat created: $chatId\n';

    // 3️⃣ Watch messages in real time
    _sub = adapter.chat.watchMessages(chatId).listen((result) {
      result.match(
            (failure) => setState(() => log += '❌ Error: ${failure.message}\n'),
            (messages) {
          setState(() {
            log += '📨 Messages (${messages.length}):\n';
            for (final msg in messages) {
              log += '   [${msg.senderId}] ${msg.text ?? '[no text]'}\n';
            }
          });
        },
      );
    });

    // 4️⃣ Send a text message
    final message = Message.text(
      chatId: chatId,
      senderId: 'user_a',
      text: 'Hello from Flutter adapter example 👋',
    );
    await adapter.chat.sendMessage(message);

    setState(() {
      initialized = true;
      log += '✅ Message sent successfully!\n';
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Converse Firebase Adapter Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase Adapter Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(log, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ),
      ),
    );
  }
}
