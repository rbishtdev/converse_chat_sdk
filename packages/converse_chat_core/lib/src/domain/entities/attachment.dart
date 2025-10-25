/// Represents a file or media attachment used in chat messages.
///
/// Supports images, videos, documents, or any file type.
/// Immutable and serializable to/from JSON for Firestore or REST APIs.
class Attachment {
  /// Unique identifier for the attachment (usually the Firebase Storage filename).
  final String id;

  /// Public or signed URL to download/view the file.
  final String url;

  /// MIME type (e.g., "image/png", "video/mp4").
  final String mimeType;

  /// File size in bytes.
  final int size;

  const Attachment({
    required this.id,
    required this.url,
    required this.mimeType,
    required this.size,
  });

  /// Creates an [Attachment] from a Firestore/JSON map.
  ///
  /// Safely casts and defaults missing fields to avoid runtime crashes.
  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      mimeType: json['mimeType']?.toString() ?? 'application/octet-stream',
      size:
          (json['size'] is int)
              ? json['size'] as int
              : int.tryParse(json['size']?.toString() ?? '0') ?? 0,
    );
  }

  /// Converts this [Attachment] into a JSON-serializable map.
  ///
  /// Used for Firestore writes, REST APIs, and local persistence.
  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'mimeType': mimeType, 'size': size};
  }

  /// Returns a copy of this attachment with optional changes.
  Attachment copyWith({String? id, String? url, String? mimeType, int? size}) {
    return Attachment(
      id: id ?? this.id,
      url: url ?? this.url,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
    );
  }

  @override
  String toString() =>
      'Attachment(id: $id, mimeType: $mimeType, size: $size, url: $url)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Attachment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          url == other.url &&
          mimeType == other.mimeType &&
          size == other.size;

  @override
  int get hashCode =>
      id.hashCode ^ url.hashCode ^ mimeType.hashCode ^ size.hashCode;
}
