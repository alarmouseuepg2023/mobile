// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserRegister {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  UserRegister({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  UserRegister copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return UserRegister(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  String toJson() => jsonEncode(toMap());
}
