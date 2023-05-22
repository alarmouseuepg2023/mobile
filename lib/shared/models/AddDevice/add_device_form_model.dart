// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AddDeviceFormModel {
  final String? wifiPassword;
  final String? ownerPassword;
  final String? nickname;
  final String? confirmOwnerPassword;

  AddDeviceFormModel(
      {this.wifiPassword,
      this.nickname,
      this.ownerPassword,
      this.confirmOwnerPassword});

  AddDeviceFormModel copyWith({
    String? wifiPassword,
    String? nickname,
    String? ownerPassword,
    String? confirmOwnerPassword,
  }) {
    return AddDeviceFormModel(
      wifiPassword: wifiPassword ?? this.wifiPassword,
      nickname: nickname ?? this.nickname,
      ownerPassword: ownerPassword ?? this.ownerPassword,
      confirmOwnerPassword: confirmOwnerPassword ?? this.confirmOwnerPassword,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'wifiPassword': wifiPassword,
      'nickname': nickname,
      'ownerPassword': ownerPassword,
      'confirmOwnerPassword': confirmOwnerPassword,
    };
  }

  String toJson() => jsonEncode(toMap());
}
