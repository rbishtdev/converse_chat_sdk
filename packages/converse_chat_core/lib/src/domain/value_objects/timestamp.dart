/// Represents a message creation timestamp (in milliseconds since epoch).
///
/// Provides utility methods for comparison and conversion.
class Timestamp {
  final int millisecondsSinceEpoch;

  const Timestamp(this.millisecondsSinceEpoch);

  /// Returns current timestamp.
  factory Timestamp.now() =>
      Timestamp(DateTime.now().millisecondsSinceEpoch);

  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

  bool isBefore(Timestamp other) =>
      millisecondsSinceEpoch < other.millisecondsSinceEpoch;

  bool isAfter(Timestamp other) =>
      millisecondsSinceEpoch > other.millisecondsSinceEpoch;

  @override
  String toString() => toDateTime().toIso8601String();

  @override
  bool operator ==(Object other) =>
      other is Timestamp &&
          other.millisecondsSinceEpoch == millisecondsSinceEpoch;

  @override
  int get hashCode => millisecondsSinceEpoch.hashCode;
}
