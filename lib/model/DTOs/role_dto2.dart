import 'package:novafarma_front/model/DTOs/task_dto.dart';
import 'package:novafarma_front/model/DTOs/task_dto1.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

class RoleDTO2 extends Deserializable<RoleDTO2> {
  String? name;
  List<TaskDTO1>? taskList;

  RoleDTO2.empty():
    name = null,
    taskList = null;

  RoleDTO2({
    required this.name,
    required this.taskList
  });

  @override
  RoleDTO2 fromJson(Map<String, dynamic> json) {
    return RoleDTO2.empty();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'taskList': taskList,
    };
  }

}