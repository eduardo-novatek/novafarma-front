import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/DTOs/role_dto.dart';

class UserDTO extends Deserializable<UserDTO> {
  final int userId;
  final String name;
  final String lastname;
  final bool active;
  final RoleDTO role;

  UserDTO.empty():
        userId = 0,
        name = "",
        lastname = "",
        active = false,
        role = RoleDTO.empty();

  UserDTO({
    required this.userId,
    required this.name,
    required this.lastname,
    required this.active,
    required this.role
  });

  /*factory RoleDTO.fromJson(Map<String, dynamic> json) {
    return RoleDTO(
      roleId: json['roleId'],
      name: json['name'],
    );
  }*/

  @override
  UserDTO fromJson(Map<String, dynamic> json) {
    return UserDTO(
      userId: json['userId'],
      name: json['name'],
      lastname: json['lastname'],
      active: json['active'],
      role: role.fromJson(json['role']),
    );
  }


}