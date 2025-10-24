import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:converse_chat_core/converse_chat_core.dart';


class FirebaseAttachmentRepository implements IAttachmentRepository {
  final FirebaseStorage storage;

  FirebaseAttachmentRepository(this.storage);

  @override
  Future<Either<ChatFailure, Attachment>> uploadAttachment({
    required String chatId,
    required String filePath,
    required String mimeType,
  }) async {
    try {
      final file = File(filePath);
      final ref = storage.ref('chats/$chatId/${file.uri.pathSegments.last}');
      //final task = await ref.putFile(file, SettableMetadata(contentType: mimeType));
      final url = await ref.getDownloadURL();

      final metadata = await ref.getMetadata();

      final attachment = Attachment(
        id: ref.name,
        url: url,
        mimeType: metadata.contentType ?? mimeType,
        size: metadata.size ?? file.lengthSync(),
      );

      return right(attachment);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<ChatFailure, String>> getAttachmentUrl(String attachmentId) async {
    try {
      final url = await storage.ref(attachmentId).getDownloadURL();
      return right(url);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<ChatFailure, Unit>> deleteAttachment(String attachmentId) async {
    try {
      await storage.ref(attachmentId).delete();
      return right(unit);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }
}
