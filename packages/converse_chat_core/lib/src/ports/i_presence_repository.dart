import 'package:fpdart/fpdart.dart';
import '../errors/chat_failure.dart';

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
  ///
  /// Returns an Either:
  /// - Right: Unit if successfully updated
  /// - Left: ChatFailure if the operation fails
  Future<Either<ChatFailure, Unit>> setUserPresence(String userId, bool isOnline);

  /// Watches presence changes for a specific user.
  ///
  /// The returned Stream emits an Either whenever the user’s status changes:
  /// - Right: `true` or `false` (online/offline)
  /// - Left: ChatFailure if a stream error occurs
  Stream<Either<ChatFailure, bool>> watchUserPresence(String userId);

  /// Updates typing status for a user within a chat.
  ///
  /// - chatId: The chat room ID.
  /// - isTyping: True if the user is currently typing.
  ///
  /// Returns:
  /// - Right: Unit if successfully updated
  /// - Left: ChatFailure if an error occurs
  Future<Either<ChatFailure, Unit>> setTypingState(
      String chatId,
      String userId,
      bool isTyping,
      );

  /// Watches typing indicators for a chat room.
  ///
  /// Emits a map where keys are `userIds` and values are their typing states.
  ///
  /// Returns:
  /// - Right: Map String, bool with current typing users
  /// - Left: ChatFailure on stream failure
  Stream<Either<ChatFailure, Map<String, bool>>> watchTypingUsers(String chatId);

  /// Returns a stream of the user’s last seen timestamp in milliseconds.
  ///
  /// - Should emit the timestamp whenever user goes offline or updates presence.
  /// - Returns `null` if the user has never been online.
  Stream<Either<ChatFailure, int?>> watchLastSeen(String userId);
}
