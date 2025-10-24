import 'package:fpdart/fpdart.dart';
import '../errors/chat_failure.dart';
import '../domain/entities/user.dart';

/// Defines the data access contract for user profiles and presence.
///
/// This port abstracts the user source — Firebase Auth, Supabase Auth,
/// or a custom backend can implement this contract.
///
/// Responsibilities include retrieving, creating, and updating user data.
abstract class IUserRepository {
  /// Returns the currently authenticated user, if any.
  ///
  /// Returns an [Either]:
  /// - [Right]: [User] if authenticated, or `null` if no user
  /// - [Left]: [ChatFailure] if fetching fails
  Future<Either<ChatFailure, User?>> getCurrentUser();

  /// Retrieves user details for a given [userId].
  ///
  /// Implementations may cache users locally for better performance.
  ///
  /// Returns:
  /// - [Right]: [User] if found
  /// - [Left]: [ChatFailure] if retrieval fails
  Future<Either<ChatFailure, User?>> getUserById(String userId);

  /// Creates or updates a user record in the data store.
  ///
  /// Called when a new user signs up or when their profile changes.
  ///
  /// Returns:
  /// - [Right]: [Unit] if operation succeeds
  /// - [Left]: [ChatFailure] if the write fails
  Future<Either<ChatFailure, Unit>> upsertUser(User user);

  /// Searches for users by text query (name, email, etc.).
  ///
  /// - [query] is a free-text string.
  /// - Returns a list of matching users.
  ///
  /// Returns:
  /// - [Right]: List<[User]> if successful
  /// - [Left]: [ChatFailure] if query fails
  Future<Either<ChatFailure, List<User>>> searchUsers(String query);

  /// Fetches all participants of a chat room.
  ///
  /// Typically used for group chat headers or mentions.
  ///
  /// Returns:
  /// - [Right]: List<[User]> participants
  /// - [Left]: [ChatFailure] if retrieval fails
  Future<Either<ChatFailure, List<User>>> getChatParticipants(String chatId);
}
