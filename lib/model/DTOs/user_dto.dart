import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/DTOs/role_dto.dart';

class UserDTO extends Deserializable<UserDTO> {
  final int? userId;
  final String name;
  final String lastname;
  final String? userName;
  final String? pass;
  final bool? active;
  final RoleDTO role;

  UserDTO.empty():
        userId = null,
        name = "",
        lastname = "",
        userName = "",
        pass = "",
        active = false,
        role = RoleDTO.empty();

  UserDTO({
    this.userId,
    this.active,
    this.userName,
    this.pass,
    required this.name,
    required this.lastname,
    required this.role
  });

  @override
  UserDTO fromJson(Map<String, dynamic> json) {
    return UserDTO(
      userId: json['userId'],
      name: json['name'],
      lastname: json['lastname'],
      userName: json['userName'],
      pass: json['pass'],
      active: json['active'],
      role: role.fromJson(json['role']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'lastname': lastname,
      'userName': userName,
      'pass': pass,
      'active': active,
      'role': role.toJson(),
    };
  }
}
