import 'package:novafarma_front/model/DTOs/role_dto1.dart';
import 'package:novafarma_front/model/DTOs/role_dto4.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

class UserDTO3 extends Deserializable<UserDTO3> {
  int? userId;
  String? name;
  String? lastname;
  RoleDTO4? role;

  UserDTO3.empty():
    userId = null,
    name = null,
    lastname = null,
    role = RoleDTO4.empty();

  UserDTO3({
    this.userId,
    required this.name,
    required this.lastname,
    required this.role
  });

  @override
  UserDTO3 fromJson(Map<String, dynamic> json) {
    return UserDTO3(
      userId: json['userId'],
      name: json['name'],
      lastname: json['lastname'],
      role: role?.fromJson(json['role']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'lastname': lastname,
      'role': role?.toJson(),
    };
  }
}
