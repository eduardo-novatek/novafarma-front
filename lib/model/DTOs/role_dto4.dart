import 'package:novafarma_front/model/DTOs/task_dto.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

class RoleDTO4 extends Deserializable<RoleDTO4> {
  int? roleId;
  String? name;
  List<TaskDTO>? taskList;

  RoleDTO4.empty():
    roleId = null,
    name = null,
    taskList = null;

  RoleDTO4({
    required this.roleId,
    required this.name,
    required this.taskList
  });

  @override
  RoleDTO4 fromJson(Map<String, dynamic> json) {
    return RoleDTO4(
      roleId: json['roleId'],
      name: json['name'],
      taskList: json['taskList']
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'name': name,
      'taskList': taskList?.map((item) => item.toJson()).toList(),
    };
  }

}