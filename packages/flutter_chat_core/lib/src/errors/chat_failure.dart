/// Unified failure model for the Chat SDK.
///
/// Used with Either<ChatFailure, T> to provide
/// consistent, typed error handling across all adapters.
sealed class ChatFailure {
  final String message;

  const ChatFailure(this.message);
}

class NetworkFailure extends ChatFailure {
  const NetworkFailure(super.msg);
}

class ServerFailure extends ChatFailure {
  const ServerFailure(super.msg);
}

class PermissionFailure extends ChatFailure {
  const PermissionFailure(super.msg);
}

class NotFoundFailure extends ChatFailure {
  const NotFoundFailure(super.msg);
}

class UnknownFailure extends ChatFailure {
  const UnknownFailure(super.msg);
}
