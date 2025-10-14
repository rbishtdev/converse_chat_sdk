import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

import '../flutter_chat_adapters.dart';


/// Combines all Firebase-based repositories into one adapter.
///
/// Allows the core SDK to depend on a single unified provider
/// that abstracts all Firebase implementations.
class FirebaseChatAdapter {
  final FirebaseChatRepository chat;
  final FirebaseUserRepository users;
  final FirebasePresenceRepository presence;
  final FirebaseAttachmentRepository attachments;

  FirebaseChatAdapter._({
    required this.chat,
    required this.users,
    required this.presence,
    required this.attachments,
  });

  /// Factory for default Firebase instances.
  static Future<FirebaseChatAdapter> createDefault() async {
    await FirebaseAdapterInitializer.ensureInitialized();

    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    final database = FirebaseDatabase.instance;

    return FirebaseChatAdapter._(
      chat: FirebaseChatRepository(firestore),
      users: FirebaseUserRepository(firestore),
      presence: FirebasePresenceRepository(database),
      attachments: FirebaseAttachmentRepository(storage),
    );
  }
}
