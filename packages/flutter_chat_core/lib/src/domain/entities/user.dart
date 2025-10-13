class User {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;

  User({required this.id, required this.name, this.avatarUrl, this.isOnline = false});
}
