// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class GuestRevoke {
  final String guestId;

  GuestRevoke({
    required this.guestId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'guestId': guestId,
    };
  }

  String toJson() => jsonEncode(toMap());
}
