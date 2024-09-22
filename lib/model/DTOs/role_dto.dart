import 'package:novafarma_front/model/DTOs/task_dto.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

class RoleDTO extends Deserializable<RoleDTO> {
  int? roleId;
  String name;
  List<TaskDTO>? taskList;
  bool? isFirst;

  RoleDTO.empty():
    roleId = 0,
    name = "",
    taskList = null,
    isFirst = null;

  RoleDTO({
    this.isFirst = false,
    required this.roleId,
    required this.name,
    required this.taskList,
  });

  @override
  RoleDTO fromJson(Map<String, dynamic> json) {
    return RoleDTO(
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

  @override
  String toString() {
    return name;
  }

}