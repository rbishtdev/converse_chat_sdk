import 'package:flutter_chat_adapters/flutter_chat_adapters.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';

/// The top-level entrypoint for using the Chat SDK.
///
/// It bundles together:
/// - Firebase initialization
/// - Repository setup
/// - Core ChatController creation
///
/// Usage:
/// ```dart
/// final chat = await ChatSDK.initialize();
/// await chat.controller.sendText(chatId: "room_1", senderId: "user_123", text: "Hi!");
/// ```
class ConverseChatClient {
  /// The main controller responsible for message operations.
  final ChatController controller;

  /// Firebase-based repositories for advanced users.
  final FirebaseChatAdapter adapter;

  /// Private constructor.
  ConverseChatClient._({
    required this.controller,
    required this.adapter,
  });

  /// Initializes the Chat SDK using Firebase as the backend.
  ///
  /// This will:
  /// - Initialize Firebase (if needed)
  /// - Setup repositories for messages, users, attachments, and presence
  /// - Create the [ChatController]
  ///
  /// Optionally, you can pass your own [FirebaseChatAdapter] instance
  /// (for custom Firebase projects or testing).
  static Future<ConverseChatClient> initialize({
    FirebaseChatAdapter? customAdapter,
  }) async {
    // Initialize Firebase safely
    await FirebaseAdapterInitializer.ensureInitialized();

    // Use provided adapter or default Firebase setup
    final adapter = customAdapter ?? await FirebaseChatAdapter.createDefault();

    // Setup message pipeline
    final pipeline = MessagePipeline(
      chatRepository: adapter.chat,
      encryption: NoEncryptionStrategy(),
      pluginRegistry: PluginRegistry(),
    );

    // Create controller
    final controller = ChatController(
      chatRepository: adapter.chat,
      attachmentRepository: adapter.attachments,
      pipeline: pipeline,
      plugins: PluginRegistry(),
    );

    return ConverseChatClient._(
      controller: controller,
      adapter: adapter,
    );
  }

  /// Cleans up all active resources, streams, and plugins.
  Future<void> dispose() async {
    await controller.dispose();
  }
}
