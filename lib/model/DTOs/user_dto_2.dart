import 'package:novafarma_front/model/DTOs/role_dto1.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

class UserDTO2 extends Deserializable<UserDTO2> {
  int? userId;
  String? name;
  String? lastname;
  RoleDTO1? role;

  UserDTO2.empty():
    userId = null,
    name = null,
    lastname = null,
    role = RoleDTO1.empty();

  UserDTO2({
    this.userId,
    required this.name,
    required this.lastname,
    required this.role
  });

  @override
  UserDTO2 fromJson(Map<String, dynamic> json) {
    return UserDTO2(
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
