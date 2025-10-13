class Attachment {
  final String url;
  final String mime;
  final int size;

  Attachment({required this.url, required this.mime, required this.size});

  Map<String, dynamic> toJson() => {'url': url, 'mime': mime, 'size': size};

  factory Attachment.fromJson(Map<String, dynamic> map) =>
      Attachment(url: map['url'], mime: map['mime'], size: map['size']);
}
