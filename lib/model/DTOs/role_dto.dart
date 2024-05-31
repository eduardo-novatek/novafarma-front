import 'package:novafarma_front/model/globals/deserializable.dart';

class RoleDTO extends Deserializable<RoleDTO> {
  final int? roleId;
  final String name;
  final bool? isFirst;

  RoleDTO.empty(): roleId = 0, name = "", isFirst = null;

  RoleDTO({this.isFirst = false, required this.roleId, required this.name,});

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

  @override
  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'name': name,
    };
  }

  @override
  String toString() {
    return name;
  }

}