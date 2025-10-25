import '../../converse_chat_core.dart';

/// Core SDK bootstrap class.
///
/// This acts as the *entry point* to your chat SDK.
/// It wires together all repositories, services, and controllers
/// into a single ready-to-use instance.
///
/// Later, you can extend [ChatSDK.initialize] to inject real adapters
/// (Firebase, Supabase, local cache, etc.).
class ChatSDK {
  /// Main chat controller used for sending & receiving messages.
  final ChatController controller;

  /// Optional plugin registry (for analytics, encryption, etc.).
  final PluginRegistry plugins;

  ChatSDK._({required this.controller, required this.plugins});

  /// Initializes the Chat SDK.
  ///
  /// Example:
  /// ```dart
  /// final sdk = await ChatSDK.initialize(
  ///   chatRepository: FirebaseChatRepository(),
  ///   userRepository: FirebaseUserRepository(),
  ///   attachmentRepository: FirebaseAttachmentRepository(),
  ///   presenceRepository: FirebasePresenceRepository(),
  /// );
  ///
  /// sdk.controller.sendText(
  ///   chatId: 'room_123',
  ///   senderId: 'user_001',
  ///   text: 'Hello world!',
  /// );
  /// ```
  static Future<ChatSDK> initialize({
    /// Required repositories implementing your domain ports.
    required IChatRepository chatRepository,
    required IUserRepository userRepository,
    required IAttachmentRepository attachmentRepository,
    required IPresenceRepository presenceRepository,
    required String currentUserId,

    /// Optional plugin registry.
    PluginRegistry? pluginRegistry,

    /// Optional encryption strategy (default: [NoEncryptionStrategy]).
    IEncryptionStrategy? encryptionStrategy,
  }) async {
    try {
      // 1️⃣ Initialize plugin system
      final plugins = pluginRegistry ?? PluginRegistry();

      // 2️⃣ Initialize encryption
      final encryption = encryptionStrategy ?? NoEncryptionStrategy();

      // 3️⃣ Build message pipeline
      final pipeline = MessagePipeline(
        chatRepository: chatRepository,
        encryption: encryption,
        pluginRegistry: plugins,
      );

      // 4️⃣ Build controller
      final controller = ChatController(
        chatRepository: chatRepository,
        attachmentRepository: attachmentRepository,
        pipeline: pipeline,
        plugins: plugins,
        currentUserId: currentUserId,
      );

      // 5️⃣ Return SDK instance
      return ChatSDK._(controller: controller, plugins: plugins);
    } catch (e, stack) {
      throw SDKInitializationException(
        'ChatSDK initialization failed: $e',
        stack,
      );
    }
  }

  /// Disposes the SDK and all registered plugins.
  Future<void> dispose() async {
    await plugins.dispose();
  }
}
