import 'attachment.dart';
import 'package:uuid/uuid.dart';

enum MessageStatus { sending, sent, delivered, read }

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String? text;
  final Attachment? attachment;
  final int createdAt;
  final List<String> readBy;
  final MessageStatus status;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.text,
    this.attachment,
    required this.createdAt,
    this.readBy = const [],
    this.status = MessageStatus.sent,
  });

  factory Message.text({
    required String chatId,
    required String senderId,
    required String text,
  }) {
    return Message(
      id: const Uuid().v4(),
      chatId: chatId,
      senderId: senderId,
      text: text,
      attachment: null,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      readBy: [],
      status: MessageStatus.sending,
    );
  }

  Message copyWith({MessageStatus? status}) {
    return Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      text: text,
      attachment: attachment,
      createdAt: createdAt,
      readBy: readBy,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'senderId': senderId,
    'text': text,
    'attachment': attachment?.toJson(),
    'createdAt': createdAt,
    'readBy': readBy,
    'status': status.name,
  };

  factory Message.fromJson(Map<String, dynamic> map) => Message(
    id: map['id'],
    chatId: map['chatId'],
    senderId: map['senderId'],
    text: map['text'],
    attachment: map['attachment'] != null
        ? Attachment.fromJson(Map<String, dynamic>.from(map['attachment']))
        : null,
    createdAt: map['createdAt'],
    readBy: List<String>.from(map['readBy'] ?? []),
    status: MessageStatus.values.firstWhere(
          (s) => s.name == (map['status'] ?? 'sent'),
      orElse: () => MessageStatus.sent,
    ),
  );
}
