import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/task_dto.dart';

class TaskSelection extends StatefulWidget {
  final List<TaskDTO> taskList;
  final Function(List<TaskDTO>) onTaskSelectionChanged;

  const TaskSelection({
    super.key,
    required this.taskList,
    required this.onTaskSelectionChanged,
  });

  @override
  State<TaskSelection> createState() => _TaskSelectionState();
}

class _TaskSelectionState extends State<TaskSelection> {
  List<TaskDTO> _selectedTasks = [];

  @override
  void initState() {
    super.initState();
    _selectedTasks = [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.taskList.map((task) {
        return CheckboxListTile(
          title: Text(task.description ?? 'Sin descripción de tarea'),
          value: _selectedTasks.contains(task),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedTasks.add(task);
              } else {
                _selectedTasks.remove(task);
              }
              widget.onTaskSelectionChanged(_selectedTasks);
            });
          },
        );
      }).toList(),
    );
  }
}
