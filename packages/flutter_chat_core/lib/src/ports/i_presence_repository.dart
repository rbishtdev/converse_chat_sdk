/// Handles user online/offline and typing states in real time.
///
/// This port abstracts presence tracking and typing indicators.
///
/// Implementations may use:
/// - Firebase Realtime Database
/// - Supabase Realtime Channels
/// - WebSocket or custom signal server
abstract class IPresenceRepository {
  /// Updates a user’s presence (online/offline).
  ///
  /// Called when user connects or disconnects from the app.
  Future<void> setUserPresence(String userId, bool isOnline);

  /// Watches presence changes for a specific user.
  ///
  /// The returned [Stream] emits `true` or `false` whenever the
  /// user’s status changes.
  Stream<bool> watchUserPresence(String userId);

  /// Updates typing status for a user within a chat.
  ///
  /// - [chatId]: The chat room ID.
  /// - [isTyping]: True if the user is currently typing.
  Future<void> setTypingState(String chatId, String userId, bool isTyping);

  /// Watches typing indicators for a chat room.
  ///
  /// Emits a map where keys are `userIds` and values are their typing states.
  Stream<Map<String, bool>> watchTypingUsers(String chatId);
}
