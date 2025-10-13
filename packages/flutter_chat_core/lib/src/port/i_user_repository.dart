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
  /// Returns `null` if no user is logged in.
  Future<User?> getCurrentUser();

  /// Retrieves user details for a given [userId].
  ///
  /// Implementations may cache users locally for better performance.
  Future<User?> getUserById(String userId);

  /// Creates or updates a user record in the data store.
  ///
  /// Called when a new user signs up or when their profile changes.
  Future<void> upsertUser(User user);

  /// Searches for users by text query (name, email, etc.).
  ///
  /// - [query] is a free-text string.
  /// - Returns a list of matching users.
  Future<List<User>> searchUsers(String query);

  /// Fetches all participants of a chat room.
  ///
  /// Typically used for group chat headers or mentions.
  Future<List<User>> getChatParticipants(String chatId);
}
