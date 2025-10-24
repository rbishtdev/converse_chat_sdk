import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:converse_chat_core/converse_chat_core.dart';

class FirebaseUserRepository implements IUserRepository {
  final FirebaseFirestore firestore;

  FirebaseUserRepository(this.firestore);

  @override
  Future<Either<ChatFailure, User?>> getCurrentUser() async {
    try {
      // Assumes user auth ID stored in local FirebaseAuth
      // Modify to use FirebaseAuth.instance.currentUser.uid if needed
      return right(null);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<ChatFailure, User?>> getUserById(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (!doc.exists) return right(null);
      return right(User.fromJson(doc.data()!));
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<ChatFailure, Unit>> upsertUser(User user) async {
    try {
      await firestore.collection('users').doc(user.id).set(user.toJson());
      return right(unit);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<ChatFailure, List<User>>> searchUsers(String query) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .get();

      final users = snapshot.docs.map((d) => User.fromJson(d.data())).toList();
      return right(users);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<ChatFailure, List<User>>> getChatParticipants(String chatId) async {
    try {
      final snapshot = await firestore.collection('chats/$chatId/participants').get();
      final users = snapshot.docs.map((d) => User.fromJson(d.data())).toList();
      return right(users);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }
}
