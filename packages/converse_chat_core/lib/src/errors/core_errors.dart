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

/// Thrown when SDK fails to initialize correctly.
class SDKInitializationException extends ChatCoreException {
  SDKInitializationException(super.message, [super.stackTrace]);
}

/// Thrown when a message fails to process in the pipeline.
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

/// Thrown when attachment upload or retrieval fails.
class AttachmentUploadException extends ChatCoreException {
  AttachmentUploadException(super.message, [super.stackTrace]);
}

/// Thrown when user fetch/update/profile operations fail.
class UserOperationException extends ChatCoreException {
   UserOperationException(super.message, [super.stackTrace]);
}

/// Fallback exception for unexpected or unmapped errors.
class UnknownChatException extends ChatCoreException {
   UnknownChatException(super.message, [super.stackTrace]);
}

/// Thrown for errors related to message operations (send, update, delete).
class MessageOperationException extends ChatCoreException {
   MessageOperationException(super.message, [super.stackTrace]);
}
