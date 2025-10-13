import '../domain/entities/attachment.dart';

/// Defines the storage abstraction for media and file attachments.
///
/// The core SDK uses this port to upload, retrieve, and delete
/// attachments (images, videos, documents, etc.).
///
/// Implementations may use:
/// - Firebase Storage
/// - Supabase Storage
/// - AWS S3
/// - Local file system
abstract class IAttachmentRepository {
  /// Uploads a file to a chat storage bucket or folder.
  ///
  /// - [chatId]: The chat where the file belongs.
  /// - [filePath]: The local file path to upload.
  /// - [mimeType]: The file’s MIME type (e.g. "image/png").
  ///
  /// Returns an [Attachment] containing metadata (URL, size, MIME type).
  Future<Attachment> uploadAttachment({
    required String chatId,
    required String filePath,
    required String mimeType,
  });

  /// Returns a public or signed URL to download an attachment.
  ///
  /// The [attachmentId] should uniquely identify the stored file.
  Future<String> getAttachmentUrl(String attachmentId);

  /// Deletes an uploaded attachment.
  ///
  /// Implementations must validate user permissions before deletion.
  Future<void> deleteAttachment(String attachmentId);
}
