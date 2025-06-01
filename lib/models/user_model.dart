import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password;

  @HiveField(3)
  DateTime createdAt;

  UserModel({
    required this.username,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}