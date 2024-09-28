import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/task_dto.dart';
import 'package:novafarma_front/model/enums/task_enum.dart';

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

  bool _isAllSelected() => _selectedTasks.any((task) => task.task == TaskEnum.all);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.taskList.map((task) {
        bool isAllSelected = _isAllSelected();
        bool isTaskAll = task.task == TaskEnum.all;
        bool isDisabled = !isTaskAll && isAllSelected; // Deshabilitar si ALL está seleccionado

        return CheckboxListTile(
          title: Text(task.description ?? 'Sin descripción de tarea'),
          value: _selectedTasks.contains(task),
          onChanged: isDisabled ? null : (bool? value) {
            setState(() {
              if (isTaskAll) { // Si la tarea ALL está seleccionada, limpiar el resto de las tareas
                if (value == true) {
                  _selectedTasks = [task];
                } else {
                  _selectedTasks.remove(task);
                }
              } else {
                if (value == true) {
                  _selectedTasks.add(task);
                } else {
                  _selectedTasks.remove(task);
                }
              }
              widget.onTaskSelectionChanged(_selectedTasks);
            });
          },
          controlAffinity: ListTileControlAffinity.leading, // Checkbox al inicio
          activeColor: Colors.blue, // Color del checkbox seleccionado
        );
      }).toList(),
    );
  }
}

/*class TaskSelection extends StatefulWidget {
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
              if (task.task == TaskEnum.all) {
                if (value == true) {

                }

              }
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
}*/
