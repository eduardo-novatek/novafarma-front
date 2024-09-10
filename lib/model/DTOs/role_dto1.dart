import 'package:novafarma_front/model/globals/deserializable.dart';

class RoleDTO1 extends Deserializable<RoleDTO1> {
  int? roleId;
  String? name;

  RoleDTO1.empty(): roleId = null, name = null;

  RoleDTO1({required this.roleId, required this.name});

  @override
  RoleDTO1 fromJson(Map<String, dynamic> json) {
    return RoleDTO1(
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

}