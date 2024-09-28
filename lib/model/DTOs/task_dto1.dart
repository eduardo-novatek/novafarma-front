import 'package:novafarma_front/model/globals/deserializable.dart';

import '../enums/task_enum.dart';

class TaskDTO1 extends Deserializable<TaskDTO1> {
  String? task;

  TaskDTO1.empty(): task = null;

  TaskDTO1({required this.task});

  @override
  TaskDTO1 fromJson(Map<String, dynamic> json) {
    return TaskDTO1(task: json['task']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'task': task};
  }

  @override
  String toString() {
    return task!;
  }

}