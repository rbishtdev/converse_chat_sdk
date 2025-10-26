import 'dart:async';

import 'package:converse_chat_core/converse_chat_core.dart';
import 'package:fpdart/fpdart.dart';

/// Converse Chat Core Example (CLI)
/// --------------------------------
/// Demonstrates core domain and message pipeline
/// without Firebase or Flutter UI.
///
/// Run with:
///   dart run example/main.dart
///
/// Expected output:
///   ✅ Message sent and streamed successfully!
Future<void> main() async {
  print('🚀 Converse Chat Core Example Started');

  // 1️⃣ Create in-memory mock repositories
  final chatRepo = _MockChatRepository();
  final attachmentRepo = _MockAttachmentRepository();

  // 2️⃣ Setup a simple pipeline
  final pipeline = MessagePipeline(
    chatRepository: chatRepo,
    encryption: NoEncryptionStrategy(),
    pluginRegistry: PluginRegistry(),
  );

  // 3️⃣ Create ChatController (no UI)
  final controller = ChatController(
    chatRepository: chatRepo,
    attachmentRepository: attachmentRepo,
    pipeline: pipeline,
    plugins: PluginRegistry(),
    currentUserId: 'user_123',
  );

  // 4️⃣ Watch messages
  controller.watchMessages('chat_1').listen((result) {
    result.match(
          (failure) => print('❌ Stream error: ${failure.message}'),
          (messages) {
        print('\n💬 Messages in chat_1:');
        for (final m in messages) {
          print('  • ${m.senderId}: ${m.text ?? "[attachment]"} [${m.status.name}]');
        }
      },
    );
  });

  // 5️⃣ Send sample messages
  await controller.sendText(
    chatId: 'chat_1',
    senderId: 'user_123',
    text: 'Hello from Converse Core 👋',
  );

  await Future.delayed(const Duration(seconds: 1));

  await controller.sendAttachment(
    chatId: 'chat_1',
    senderId: 'user_123',
    filePath: '/fake/path/image.png',
    mimeType: 'image/png',
  );

  await Future.delayed(const Duration(seconds: 1));
  print('\n✅ Example finished successfully!');
}

/// ---------------------------------------------------------------------------
/// 🔹 MOCK CHAT REPOSITORY (in-memory, no backend)
/// ---------------------------------------------------------------------------
class _MockChatRepository implements IChatRepository {
  final List<Message> _messages = [];
  final _controller = StreamController<Either<ChatFailure, List<Message>>>.broadcast();

  @override
  Stream<Either<ChatFailure, List<Message>>> watchMessages(String chatId, {int limit = 50}) {
    // Emit initial list immediately
    _controller.add(right(_messages));
    return _controller.stream;
  }

  @override
  Future<Either<ChatFailure, Unit>> sendMessage(Message message) async {
    final updated = message.copyWith(status: MessageStatus.sent);
    _messages.add(updated);
    _controller.add(right(List.from(_messages)));
    return right(unit);
  }

  @override
  Future<Either<ChatFailure, List<Message>>> fetchMessages(
      String chatId, {
        String? beforeMessageId,
        int limit = 50,
      }) async {
    return right(List.from(_messages));
  }

  @override
  Future<Either<ChatFailure, Unit>> markAsRead(String chatId, String messageId, String userId) async {
    return right(unit);
  }

  @override
  Future<Either<ChatFailure, Unit>> deleteMessage(String chatId, String messageId) async {
    _messages.removeWhere((m) => m.id == messageId);
    _controller.add(right(List.from(_messages)));
    return right(unit);
  }

  @override
  Future<Either<ChatFailure, Unit>> updateMessage(String chatId, Message message) async {
    return right(unit);
  }

  @override
  Future<Either<ChatFailure, void>> updateMessageStatus(
      String chatId,
      String messageId,
      MessageStatus status,
      ) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(status: status);
      _controller.add(right(List.from(_messages)));
    }
    return right(null);
  }

  @override
  Future<Either<ChatFailure, String>> createOrJoinChat(String userA, String userB) async {
    return right('chat_1');
  }
}

/// ---------------------------------------------------------------------------
/// 🔹 MOCK ATTACHMENT REPOSITORY (just simulates uploads)
/// ---------------------------------------------------------------------------
class _MockAttachmentRepository implements IAttachmentRepository {
  @override
  Future<Either<ChatFailure, Attachment>> uploadAttachment({
    required String chatId,
    required String filePath,
    required String mimeType,
  }) async {
    print('📎 Uploading attachment for $chatId: $filePath');
    await Future.delayed(const Duration(milliseconds: 500));

    return right(Attachment(
      id: 'att_${DateTime.now().millisecondsSinceEpoch}',
      url: 'https://example.com/$filePath',
      mimeType: mimeType,
      size: 1024,
    ));
  }

  @override
  Future<Either<ChatFailure, String>> getAttachmentUrl(String attachmentId) async {
    return right('https://example.com/$attachmentId');
  }

  @override
  Future<Either<ChatFailure, Unit>> deleteAttachment(String attachmentId) async {
    return right(unit);
  }
}
