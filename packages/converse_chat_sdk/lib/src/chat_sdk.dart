import 'package:converse_chat_adapters/converse_chat_adapters.dart';
import 'package:converse_chat_core/converse_chat_core.dart';
import 'package:fpdart/fpdart.dart';

/// 🧩 **ConverseChatClient**
///
/// The top-level entrypoint for using the **Converse Chat SDK**.
///
/// This class orchestrates:
/// - Firebase initialization
/// - Repository setup for messages, users, presence & attachments
/// - Message pipeline configuration
///
/// It provides a **developer-friendly, domain-based API**:
/// - `chat.messages` → Send & watch messages
/// - `chat.users` → Manage user profiles
/// - `chat.presence` → Track online status & typing indicators
/// - `chat.attachments` → Upload & download media
///
/// Example usage:
/// ```dart
/// final chat = await ConverseChatClient.initialize(currentUserId: "user_123");
///
/// // 🔹 Send a message
/// await chat.messages.sendText(chatId: "room_1", senderId: "user_123", text: "Hello");
///
/// // 🔹 Watch for updates
/// chat.messages.watchMessages("room_1").listen(print);
///
/// // 🔹 Manage presence
/// await chat.presence.setUserPresence("user_123", true);
/// chat.presence.watchUserPresence("user_456").listen((online) => print("User online: $online"));
///
/// // 🔹 Upload attachments
/// await chat.attachments.uploadAttachment(
///   chatId: "room_1",
///   filePath: "path/to/image.png",
///   mimeType: "image/png",
/// );
/// ```
class ConverseChatClient {
  // ---------------------------------------------------------------------------
  // 🧠 CORE DOMAINS
  // ---------------------------------------------------------------------------

  /// Handles all **message-related operations** — sending, receiving,
  /// marking as read, and real-time streaming of messages.
  final ChatController messages;

  /// Provides **user management** capabilities — fetching profiles,
  /// searching users, and getting chat participants.
  final IUserRepository users;

  /// Manages **presence tracking** — online/offline state and typing indicators.
  final IPresenceRepository presence;

  /// Handles **file and media attachments** — uploading, downloading, and deletion.
  final IAttachmentRepository attachments;

  /// Internal Firebase adapter reference (used for dependency injection).
  ///
  /// This is intentionally private to prevent SDK users from depending
  /// on a specific backend (Firebase). In future, you can swap it for
  /// Supabase, REST, or other adapters without changing the public API.
  /// ignore: unused_field
  final FirebaseChatAdapter _adapter;

  // ---------------------------------------------------------------------------
  // 🔹 PRIVATE CONSTRUCTOR
  // ---------------------------------------------------------------------------

  /// Internal constructor — used by [initialize].
  ///
  /// Developers should never call this directly; use
  /// [ConverseChatClient.initialize()] instead.
  ConverseChatClient._({
    required this.messages,
    required this.users,
    required this.presence,
    required this.attachments,
    required FirebaseChatAdapter adapter,
  }) : _adapter = adapter;

  // ---------------------------------------------------------------------------
  // 🚀 INITIALIZATION
  // ---------------------------------------------------------------------------

  /// Initializes the **Converse Chat SDK**.
  ///
  /// This method:
  /// - Ensures Firebase is initialized (if not already)
  /// - Creates and wires all repositories & services
  /// - Configures the message pipeline
  ///
  /// You must provide:
  /// - [currentUserId]: the unique ID of the logged-in user
  ///
  /// Optionally:
  /// - [customAdapter]: inject your own adapter (e.g., for custom Firebase app)
  ///
  /// Example:
  /// ```dart
  /// final chat = await ConverseChatClient.initialize(
  ///   currentUserId: FirebaseAuth.instance.currentUser!.uid,
  /// );
  /// ```
  static Future<ConverseChatClient> initialize({
    required String currentUserId,
    FirebaseChatAdapter? customAdapter,
  }) async {
    // 1️⃣ Ensure Firebase is ready
    await FirebaseAdapterInitializer.ensureInitialized();

    // 2️⃣ Use provided or default adapter
    final adapter = customAdapter ?? await FirebaseChatAdapter.createDefault();

    // 3️⃣ Build the message pipeline (encryption, plugins, etc.)
    final pipeline = MessagePipeline(
      chatRepository: adapter.chat,
      encryption: NoEncryptionStrategy(),
      pluginRegistry: PluginRegistry(),
    );

    // 4️⃣ Create message controller
    final messages = ChatController(
      chatRepository: adapter.chat,
      attachmentRepository: adapter.attachments,
      pipeline: pipeline,
      plugins: PluginRegistry(),
      currentUserId: currentUserId,
    );

    // 5️⃣ Return a fully wired SDK client
    return ConverseChatClient._(
      messages: messages,
      users: adapter.users,
      presence: adapter.presence,
      attachments: adapter.attachments,
      adapter: adapter,
    );
  }

  // ---------------------------------------------------------------------------
  // 🌐 PRESENCE SHORTCUT HELPERS
  // ---------------------------------------------------------------------------

  /// Sets the current user's **online or offline** status.
  ///
  /// Call this:
  /// - On app start → `true`
  /// - On app close or logout → `false`
  ///
  /// Example:
  /// ```dart
  /// await chat.setOnlineStatus(userId, true);
  /// ```
  Future<void> setOnlineStatus(String userId, bool isOnline) async {
    await presence.setUserPresence(userId, isOnline);
  }

  /// Watches a user's **online/offline presence** in real-time.
  ///
  /// Returns a [Stream] of `Either<ChatFailure, bool>`,
  /// where `true` means online and `false` means offline.
  ///
  /// Example:
  /// ```dart
  /// chat.watchUserPresence("user_456").listen((either) {
  ///   either.match(
  ///     (failure) => print("Error: ${failure.message}"),
  ///     (isOnline) => print("User is ${isOnline ? 'online' : 'offline'}"),
  ///   );
  /// });
  /// ```
  Stream<Either<ChatFailure, bool>> watchUserPresence(String userId) {
    return presence.watchUserPresence(userId);
  }

  /// Updates the **typing state** for a user inside a chat.
  ///
  /// Call this when:
  /// - Typing starts → `true`
  /// - Typing stops → `false`
  ///
  /// Example:
  /// ```dart
  /// chat.setTypingState(chatId, userId, true);
  /// ```
  Future<void> setTypingState(String chatId, String userId, bool isTyping) async {
    await presence.setTypingState(chatId, userId, isTyping);
  }

  /// Watches **typing indicators** for a chat.
  ///
  /// Returns a [Stream] of user typing states:
  /// ```dart
  /// {
  ///   "user_123": true,
  ///   "user_456": false,
  /// }
  /// ```
  Stream<Either<ChatFailure, Map<String, bool>>> watchTypingUsers(String chatId) {
    return presence.watchTypingUsers(chatId);
  }

  // ---------------------------------------------------------------------------
  // 🧹 CLEANUP
  // ---------------------------------------------------------------------------

  /// Disposes of all controllers, plugins, and active listeners.
  ///
  /// Call this when your app closes or the SDK is no longer needed.
  Future<void> dispose() async {
    await messages.dispose();
  }

  /// Ensures that a 1-on-1 chat exists between two users.
  ///
  /// Returns the chat ID as `Right(chatId)` on success,
  /// or `Left(ChatFailure)` on failure.
  ///
  /// Example:
  /// ```dart
  /// final chatIdResult = await chat.ensureChatExist("user_1", "user_2");
  /// chatIdResult.match(
  ///   (failure) => print("Failed: ${failure.message}"),
  ///   (chatId) => print("Chat ready: $chatId"),
  /// );
  /// ```
  Future<Either<ChatFailure, String>> ensureChatExists(
      String userA,
      String userB,
      ) async {
    return await messages.chatRepository.ensureChatExists(userA, userB);
  }

  /// Watches the last seen timestamp for a specific user.
  ///
  /// Emits either `null` (never online) or an integer timestamp in milliseconds.
  ///
  /// Example:
  /// ```dart
  /// chat.watchLastSeen("user_123").listen((result) {
  ///   result.match(
  ///     (failure) => print("Error: ${failure.message}"),
  ///     (lastSeen) {
  ///       if (lastSeen != null) print("Last seen at: $lastSeen");
  ///     },
  ///   );
  /// });
  /// ```
  Stream<Either<ChatFailure, int?>> watchLastSeen(String userId) {
    return presence.watchLastSeen(userId);
  }
}
