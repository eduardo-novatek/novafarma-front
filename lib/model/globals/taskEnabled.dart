import 'package:novafarma_front/model/enums/task_enum.dart';
import 'package:novafarma_front/model/globals/publics.dart';

/// True si tiene todas las tareas o si la tarea está habilitada para el usuario logueado.
bool taskEnabled(TaskEnum taskEnum) =>
    userLogged!.role!.taskList![0].task == TaskEnum.all ||
    userLogged!.role!.taskList!.indexWhere(
        (taskDTO) => taskDTO.task?.name == taskEnum.name
    ) >= 0;
