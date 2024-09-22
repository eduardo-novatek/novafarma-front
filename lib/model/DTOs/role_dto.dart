import 'package:novafarma_front/model/DTOs/task_dto.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

import '../enums/task_enum.dart';

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
      taskList: json['taskList'] != null ? _getTaskDTOList(json) : null,
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

  List<TaskDTO> _getTaskDTOList(Map<String, dynamic> json) {
    return List<TaskDTO>.from(
      json['taskList'].map((item) => TaskDTO(
        taskId: item['taskId'],
        task: toTaskEnumFromBackend(item['task']),
        description: item['description'],
      ))
    );
  }

  @override
  String toString() {
    return name;
  }

}