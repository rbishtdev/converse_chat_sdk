import 'package:flutter_chat_adapters/flutter_chat_adapters.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:fpdart/fpdart.dart';

/// The top-level entrypoint for using the Chat SDK.
///
/// It bundles together:
/// - Firebase initialization
/// - Repository setup
/// - Core ChatController creation
/// - Presence & typing state management
///
/// Example usage:
/// ```dart
/// final chat = await ConverseChatClient.initialize();
/// await chat.controller.sendText(chatId: "room_1", senderId: "user_123", text: "Hi!");
/// await chat.setOnlineStatus("user_123", true);
/// chat.watchUserPresence("user_456").listen((online) => print(online));
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
    required String currentUserId,
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
      currentUserId: currentUserId,
    );

    return ConverseChatClient._(
      controller: controller,
      adapter: adapter,
    );
  }

  // ---------------------------------------------------------------------------
  // 🔹 PRESENCE & TYPING MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Marks a user as online or offline.
  ///
  /// Call this on app start (`true`) and on dispose or logout (`false`).
  Future<void> setOnlineStatus(String userId, bool isOnline) async {
    await adapter.presence.setUserPresence(userId, isOnline);
  }

  /// Watches the online status of a specific user.
  ///
  /// Emits `true` when the user is online, `false` otherwise.
  Stream<Either<ChatFailure, bool>> watchUserPresence(String userId) {
    return adapter.presence.watchUserPresence(userId);
  }

  /// Sets the typing state for the current user in a given chat.
  ///
  /// Use `true` when user starts typing, `false` when stops.
  Future<void> setTypingState(String chatId, String userId, bool isTyping) async {
    await adapter.presence.setTypingState(chatId, userId, isTyping);
  }

  /// Watches typing indicators for a specific chat.
  ///
  /// Emits a map where keys are userIds and values indicate typing state.
  Stream<Either<ChatFailure, Map<String, bool>>> watchTypingUsers(String chatId) {
    return adapter.presence.watchTypingUsers(chatId);
  }

  // ---------------------------------------------------------------------------
  // 🔹 CLEANUP
  // ---------------------------------------------------------------------------

  /// Cleans up all active resources, streams, and plugins.
  Future<void> dispose() async {
    await controller.dispose();
  }
}
