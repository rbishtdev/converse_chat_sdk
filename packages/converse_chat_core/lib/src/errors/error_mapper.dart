import 'chat_failure.dart';
import 'core_errors.dart';

/// Maps functional [ChatFailure] instances into
/// throwable [ChatCoreException]s for SDK consumers.
///
/// This keeps the domain layer pure (functional) while still
/// providing ergonomic try/catch-based error handling at the SDK surface.
class ErrorMapper {
  /// Converts a [ChatFailure] into a concrete [ChatCoreException].
  static ChatCoreException toException(ChatFailure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure _:
        return MessageOperationException('Network error: ${failure.message}');
      case ServerFailure _:
        return MessageOperationException('Server error: ${failure.message}');
      case PermissionFailure _:
        return UserOperationException('Permission denied: ${failure.message}');
      case NotFoundFailure _:
        return UserOperationException('Resource not found: ${failure.message}');
      case UnknownFailure _:
        return UnknownChatException('Unexpected error: ${failure.message}');
      default:
        return UnknownChatException(failure.message);
    }
  }

  /// Optionally, convert an [Exception] or [Error] (from Firebase, REST, etc.)
  /// into a [ChatFailure].
  ///
  /// This can be used inside repositories or adapters to unify errors.
  static ChatFailure fromException(Object e) {
    final message = e.toString();

    if (message.contains('network') || message.contains('timeout')) {
      return NetworkFailure(message);
    } else if (message.contains('permission') ||
        message.contains('unauthorized')) {
      return PermissionFailure(message);
    } else if (message.contains('not found')) {
      return NotFoundFailure(message);
    } else if (message.contains('server')) {
      return ServerFailure(message);
    } else {
      return UnknownFailure(message);
    }
  }
}
