// ignore_for_file: public_member_api_docs, sort_constructors_first

class Device {
  final String id;
  final String nickname;
  final String role;
  final String status;
  final String macAddress;
  final String wifiSsid;
  final String ownerName;

  Device({
    required this.id,
    required this.macAddress,
    required this.nickname,
    required this.wifiSsid,
    required this.role,
    required this.status,
    required this.ownerName,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'],
        macAddress: json['macAddress'],
        wifiSsid: json['wifiSsid'],
        nickname: json['nickname'],
        role: json['role'],
        status: json['status'],
        ownerName: json['ownerName'],
      );

  @override
  String toString() {
    return '{ id: $id, nickname: $nickname, wifiSsid: $wifiSsid, macAddress: $macAddress, role: $role, status: $status, ownerName: $ownerName }';
  }
}
