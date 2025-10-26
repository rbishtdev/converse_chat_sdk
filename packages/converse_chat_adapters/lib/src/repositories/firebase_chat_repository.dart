import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:converse_chat_core/converse_chat_core.dart';
import 'package:fpdart/fpdart.dart';

class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore firestore;

  FirebaseChatRepository(this.firestore);

  @override
  Stream<Either<ChatFailure, List<Message>>> watchMessages(
      String chatId, {
        int limit = 50,
      }) {
    try {
      final stream = firestore
          .collection('chats/$chatId/messages')
          .orderBy('createdAt', descending: false)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        final messages = snapshot.docs.map((d) {
          return Message.fromJson(d.data());
        }).toList();
        return right<ChatFailure, List<Message>>(messages);
      });

      return stream.handleError((e) => left(ErrorMapper.fromException(e)));
    } catch (e) {
      return Stream.value(left(ErrorMapper.fromException(e)));
    }
  }

  @override
  Future<Either<ChatFailure, Unit>> sendMessage(Message message) async {
    try {
      final docRef = firestore
          .collection('chats/${message.chatId}/messages')
          .doc(message.id);

      // 1️⃣ Write message with initial status
      await docRef.set(message.toJson());

      // 2️⃣ Immediately update status → sent
      await docRef.update({'status': MessageStatus.sent.name});

      return right(unit);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<ChatFailure, List<Message>>> fetchMessages(
      String chatId, {
        String? beforeMessageId,
        int limit = 50,
      }) async {
    try {
      // Explicitly typed query (important for Firestore generics)
      Query<Map<String, dynamic>> query = firestore
          .collection('chats/$chatId/messages')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // 🔹 Handle pagination if beforeMessageId is provided
      if (beforeMessageId != null) {
        final doc = await firestore
            .collection('chats/$chatId/messages')
            .doc(beforeMessageId)
            .get();

        if (doc.exists) {
          query = query.startAfterDocument(doc);
        }
      }

      // 🔹 Execute query and safely deserialize
      final snapshot = await query.get();
      final messages = snapshot.docs
          .map((d) => Message.fromJson(d.data())).toList();

      return right(messages);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }


  @override
  Future<Either<ChatFailure, Unit>> markAsRead(
      String chatId,
      String messageId,
      String userId,
      ) async {
    try {
      await firestore
          .collection('chats/$chatId/messages')
          .doc(messageId)
          .update({'readBy.$userId': true});
      return right(unit);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<ChatFailure, Unit>> deleteMessage(
      String chatId,
      String messageId,
      ) async {
    try {
      await firestore.collection('chats/$chatId/messages').doc(messageId).delete();
      return right(unit);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<ChatFailure, Unit>> updateMessage(
      String chatId,
      Message message,
      ) async {
    try {
      await firestore
          .collection('chats/$chatId/messages')
          .doc(message.id)
          .update(message.toJson());
      return right(unit);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<ChatFailure, String>> createOrJoinChat(
      String userAId,
      String userBId,
      ) async {
    try {
      final chatId = ChatIdGenerator.forDirectChat(userAId, userBId);
      final chatRef = firestore.collection('chats').doc(chatId);

      final chatDoc = await chatRef.get();
      if (!chatDoc.exists) {
        await chatRef.set({
          'id': chatId,
          'participants': [userAId, userBId],
          'isGroup': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return right(chatId);
    } catch (e) {
      return left(UnknownFailure('Failed to ensure chat: $e'));
    }
  }

  @override
  Future<Either<ChatFailure, void>> updateMessageStatus(
      String chatId,
      String messageId,
      MessageStatus status,
      ) async {
    try {
      await firestore
          .collection('chats/$chatId/messages')
          .doc(messageId)
          .update({'status': status.name});
      return right(null);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }

}
