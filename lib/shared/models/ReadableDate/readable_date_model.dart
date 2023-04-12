// ignore_for_file: public_member_api_docs, sort_constructors_first
class ReadableDate {
  final String readableDate;
  final String timestamp;

  ReadableDate({
    required this.readableDate,
    required this.timestamp,
  });

  factory ReadableDate.fromJson(Map<String, dynamic> json) => ReadableDate(
      readableDate: json['readableDate'], timestamp: json['timestamp']);

  @override
  String toString() => '{ readableDate: $readableDate, timestamp: $timestamp }';
}
