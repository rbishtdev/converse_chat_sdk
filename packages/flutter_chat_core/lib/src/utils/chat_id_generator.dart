import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// Generates chat IDs for 1:1 and group conversations.
class ChatIdGenerator {
  static String forDirectChat(String userA, String userB) {
    final users = [userA, userB]..sort();
    final raw = '${users[0]}_${users[1]}';
    final hash = sha256.convert(utf8.encode(raw)).toString().substring(0, 20);
    return 'dm_$hash';
  }

  static String forGroupChat() {
    final uuid = const Uuid().v4();
    return 'grp_$uuid';
  }
}
