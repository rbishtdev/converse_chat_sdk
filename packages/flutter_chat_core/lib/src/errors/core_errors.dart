/// Base class for all SDK-level exceptions.
///
/// Each module (auth, chat, storage) can define its own subclasses
/// for specific error cases.
abstract class ChatCoreException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  ChatCoreException(this.message, [this.stackTrace]);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a message fails to pass through the pipeline.
class MessagePipelineException extends ChatCoreException {
  MessagePipelineException(super.message, [super.stackTrace]);
}

/// Thrown when encryption or decryption fails.
class EncryptionException extends ChatCoreException {
  EncryptionException(super.message, [super.stackTrace]);
}

/// Thrown when a plugin throws an unexpected error.
class PluginException extends ChatCoreException {
  PluginException(super.message, [super.stackTrace]);
}
