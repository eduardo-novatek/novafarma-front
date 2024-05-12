import 'package:novafarma_front/model/globals/deserializable.dart';

class RoleDTO extends Deserializable<RoleDTO> {
  final int roleId;
  final String name;

  RoleDTO.empty(): roleId = 0, name = "";

  RoleDTO({required this.roleId, required this.name,});

  /*factory RoleDTO.fromJson(Map<String, dynamic> json) {
    return RoleDTO(
      roleId: json['roleId'],
      name: json['name'],
    );
  }*/

  @override
  RoleDTO fromJson(Map<String, dynamic> json) {
    return RoleDTO(
      roleId: json['roleId'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'name': name,
    };
  }

}