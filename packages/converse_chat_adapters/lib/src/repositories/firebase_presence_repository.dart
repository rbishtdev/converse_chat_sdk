import 'package:firebase_database/firebase_database.dart';
import 'package:fpdart/fpdart.dart';
import 'package:converse_chat_core/converse_chat_core.dart';

class FirebasePresenceRepository implements IPresenceRepository {
  final FirebaseDatabase database;

  FirebasePresenceRepository(this.database);

  @override
  Future<Either<ChatFailure, Unit>> setUserPresence(
      String userId,
      bool isOnline,
      ) async {
    try {
      final ref = database.ref('presence/$userId');

      await ref.update({
        'online': isOnline,
        'lastSeen': isOnline
            ? ServerValue.timestamp
            : DateTime.now().millisecondsSinceEpoch,
      });

      return right(unit);
    } catch (e) {
      return left<ChatFailure, Unit>(ErrorMapper.fromException(e));
    }
  }

  @override
  Stream<Either<ChatFailure, bool>> watchUserPresence(String userId) {
    try {
      final ref = database.ref('presence/$userId/online');
      return ref.onValue.map((event) {
        final online = event.snapshot.value == true;
        return right<ChatFailure, bool>(online);
      }).handleError((e) => left(ErrorMapper.fromException(e)));
    } catch (e) {
      return Stream.value(left(ErrorMapper.fromException(e)));
    }
  }

  @override
  Future<Either<ChatFailure, Unit>> setTypingState(
      String chatId,
      String userId,
      bool isTyping,
      ) async {
    try {
      await database.ref('typing/$chatId/$userId').set({'typing': isTyping});
      return right(unit);
    } catch (e) {
      return left(ErrorMapper.fromException(e));
    }
  }

  @override
  Stream<Either<ChatFailure, Map<String, bool>>> watchTypingUsers(String chatId) {
    try {
      final ref = database.ref('typing/$chatId');
      return ref.onValue.map((event) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final map = data.map((k, v) => MapEntry(k, v['typing'] == true));
        return right<ChatFailure, Map<String, bool>>(map);
      }).handleError((e) => left(ErrorMapper.fromException(e)));
    } catch (e) {
      return Stream.value(left(ErrorMapper.fromException(e)));
    }
  }

  @override
  Stream<Either<ChatFailure, int?>> watchLastSeen(String userId) {
    try {
      final ref = database.ref('presence/$userId/lastSeen');

      return ref.onValue.map((event) {
        final value = event.snapshot.value;

        if (value is int) {
          // ✅ Explicitly cast to correct Either type
          return right<ChatFailure, int?>(value);
        }

        // ✅ Even when null, still type as Either<ChatFailure, int?>
        return right<ChatFailure, int?>(null);
      }).handleError(
            (e) => left<ChatFailure, int?>(ErrorMapper.fromException(e)),
      );
    } catch (e) {
      // ✅ Wrap in a Stream with correct generic type
      return Stream.value(left<ChatFailure, int?>(ErrorMapper.fromException(e)));
    }
  }
}
