import 'package:novafarma_front/model/globals/deserializable.dart';

import '../enums/task_enum.dart';

class TaskDTO extends Deserializable<TaskDTO> {
  int? taskId;
  TaskEnum? task;
  String? description;
  bool? isFirst;

  TaskDTO.empty():
    taskId = null,
    task = null,
    description = null,
    isFirst = null;

  TaskDTO({
    this.isFirst = false,
    required this.taskId,
    required this.task,
    required this.description
  });

  @override
  TaskDTO fromJson(Map<String, dynamic> json) {
    return TaskDTO(
      taskId: json['taskId'],
      task: toTaskEnumFromBackend(json['task']),
      description: json['description']
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'roleId': taskId,
      'task': task,
      'description': description
    };
  }

  @override
  String toString() {
    return description!;
  }

}