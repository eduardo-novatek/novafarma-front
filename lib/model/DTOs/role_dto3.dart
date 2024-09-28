import 'package:novafarma_front/model/DTOs/task_dto.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

class RoleDTO3 extends Deserializable<RoleDTO3> {
  int? roleId;
  String? name;

  RoleDTO3.empty():
    roleId = null,
    name = null;

  RoleDTO3({
    required this.roleId,
    required this.name,
  });

  @override
  RoleDTO3 fromJson(Map<String, dynamic> json) {
    return RoleDTO3(
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
  String toString() => name ?? '';

}