// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/empty_dto.dart';
import 'package:novafarma_front/model/DTOs/role_dto.dart';
import 'package:novafarma_front/model/DTOs/role_dto1.dart';
import 'package:novafarma_front/model/DTOs/role_dto2.dart';
import 'package:novafarma_front/model/DTOs/role_dto3.dart';
import 'package:novafarma_front/model/DTOs/user_dto.dart';
import 'package:novafarma_front/model/DTOs/user_dto_2.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/enums/request_type_enum.dart';
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/globals/tools/custom_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/fetch_data_object.dart';
import 'package:novafarma_front/model/globals/constants.dart' show uriRoleAdd, uriRoleAddTasks, uriRoleDelete, uriRoleDeleteTasks, uriRoleFindAll, uriRoleUpdate, uriTaskFindAll, uriUserActivate, uriUserAdd, uriUserChangeCredentials, uriUserDelete, uriUserFindAll, uriUserUpdate;
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';
import 'package:novafarma_front/model/objects/error_object.dart';
import 'package:novafarma_front/view/dialogs/role_add_or_tasks_update_dialog.dart';
import 'package:novafarma_front/view/dialogs/change_role_name_dialog.dart';
import 'package:novafarma_front/view/dialogs/user_edit_dialog.dart';
import '../../model/DTOs/task_dto.dart';
import '../../model/DTOs/task_dto1.dart';
import '../../model/enums/task_enum.dart';
import '../../model/globals/tools/build_circular_progress.dart';
import '../dialogs/user_add_dialog.dart';

class UserRoleTaskScreen extends StatefulWidget {
  const UserRoleTaskScreen({super.key});

  @override
  State<UserRoleTaskScreen> createState() => UserRoleTaskScreenState();
}

class UserRoleTaskScreenState extends State<UserRoleTaskScreen> {
  final List<UserDTO> _userList = [];
  final List<RoleDTO> _roleList = [];
  final List<TaskDTO> _taskList = [];

  bool _loadingUsers = false;
  bool _loadingRolesAndTasks = false;
  int? _hoveredUserIndex;  // Índice de hover para el panel de usuarios
  int? _hoveredRoleAndTaskIndex;  // Índice de hover para el panel de roles

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadRoles();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildContainer('Usuarios', Icons.person, _userList, _loadingUsers),
        _buildContainer('Roles y tareas', Icons.group, _roleList, _loadingRolesAndTasks),
      ],
    );
  }

  Widget _buildContainer(
      String title, IconData icon, List<dynamic> dataList, bool loading) {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Colors.black54),
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHead(title, icon),
            Expanded(
              child: IgnorePointer(
                ignoring: loading,
                child: _buildBody(dataList, loading),
              ),
            ),
            _buildFooter(title),
          ],
        ),
      ),
    );
  }

  ClipRRect _buildHead(String title, IconData icon) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(18.0),
        topRight: Radius.circular(18.0),
      ),
      child: Container(
        color: title == 'Roles y tareas' ? Colors.blue : Colors.green,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, color: Colors.white
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: title == 'Roles y tareas' ? _loadRoles : _loadUsers,
              color: Colors.white,
              tooltip: "Actualizar",
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<dynamic> dataList, bool loading) {
    return Stack(
      children: [
        ListView.builder(
          itemCount: dataList.length,
          itemBuilder: (context, index) {
            return dataList is List<UserDTO>
                ? _buildUserData(dataList[index], index)
                : _buildRoleData(dataList[index], index);
          },
        ),
        // AbsorbPointer para bloquear la interacción cuando está cargando
        if (loading)
          AbsorbPointer(
            absorbing: loading,
            child: buildCircularProgress(size: 30.0), //CircularProgressIndicator(),
          )
      ],
    );
  }

  Container _buildFooter(String title) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: title == 'Roles y tareas' ? Colors.blue : Colors.green,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18.0),
          bottomRight: Radius.circular(18.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 30.0,
            tooltip: 'Agregar $title',
            onPressed: () {
              if (title == 'Usuarios') {
                _addUser();
              } else if (title == 'Roles y tareas') {
                _addRole();
              }
            },
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleData(RoleDTO role, int index) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredRoleAndTaskIndex = index;  // Establece el índice del elemento en hover para roles
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredRoleAndTaskIndex = null;  // Desactiva el hover
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _hoveredRoleAndTaskIndex == index ? Colors.grey.shade300 : Colors.white,  // Cambia de color en hover
          border: Border(
            left: BorderSide(
              color: _hoveredRoleAndTaskIndex == index ? Colors.blue : Colors.transparent,  // Cambia de color el borde en hover
              width: 5,
            ),
          ),
        ),
        child: ExpansionTile(
          title: Text(role.name),
          trailing: PopupMenuButton<String>(
            tooltip: '',
            onSelected: (value) {
              switch (value) {
                case 'Cambiar nombre':
                  _changeRoleName(role);
                  break;
                case 'Agregar tareas':
                  _addTaskToRole(role);
                  break;
                case 'Eliminar rol':
                  _deleteRole(role);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Cambiar nombre',
                child: Text('Cambiar nombre'),
              ),
              const PopupMenuItem<String>(
                value: 'Agregar tareas',
                child: Text('Agregar tareas'),
              ),
              const PopupMenuItem<String>(
                value: 'Eliminar rol',
                child: Text('Eliminar rol', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          children: [
            if (role.taskList != null)
              _buildTaskList(role),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(RoleDTO role) {
    return Column(
      children: role.taskList!.map((taskDTO) {
        return Container(
          padding: const EdgeInsets.only(left: 16.0, right: 30.0),
          height: 25,  // Altura mínima para cada tarea
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  taskDTO.description!,
                  style: const TextStyle(fontSize: 14.0),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 18.0,),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24,),
                onPressed: () {
                  _removeTasksFromRole(role, [toBackendFormat(taskDTO.task!)]);
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _removeTasksFromRole(
      RoleDTO role, List<String> taskBackendEnums) async {
    _setLoading(isUsers: false, loading: true);
    await fetchDataObject<TaskDTO>(
        uri: '$uriRoleDeleteTasks/${role.roleId}',
        classObject: TaskDTO.empty(),
        requestType: RequestTypeEnum.delete,
        body: taskBackendEnums
    ).then((value) {
      _loadRoles();
    }).onError((error, stackTrace) {
      if (error is ErrorObject) {
        FloatingMessage.show(
          context: context,
          text: error.message!,
          messageTypeEnum: MessageTypeEnum.warning
        );
      } else {
        genericError(error!, context, isFloatingMessage: true);
      }
    });
    _setLoading(isUsers: false, loading: false);
  }

  Widget _buildUserData(UserDTO user, int index) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredUserIndex = index;  // Establece el índice del elemento en hover para usuarios
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredUserIndex = null;  // Desactiva el hover
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _hoveredUserIndex == index ? Colors.grey.shade300 : Colors.white,  // Cambia de color en hover
          border: Border(
            left: BorderSide(
              color: _hoveredUserIndex == index ? Colors.blue : Colors.transparent,  // Cambia de color el borde en hover
              width: 5,
            ),
          ),
        ),
        child: ListTile(
          title: Text('${user.name} ${user.lastname} (${user.role!.name})'),
          subtitle: _buildSubtitle(user),
          trailing: PopupMenuButton<String>(
            tooltip: '',
            onSelected: (value) {
              switch (value) {
                case 'Editar':
                  _editUser(user);
                  break;
                case 'Activar/Desactivar':
                  _activateOrDeactivate(user);
                  break;
                case 'Restablecer Contraseña':
                  _resetPass(user);
                  break;
                case 'Eliminar':
                  _deleteUser(user);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  '${user.name} ${user.lastname} (${user.role!.name})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const PopupMenuDivider(height: 0,),
              const PopupMenuItem<String>(
                value: 'Editar',
                child: Text('Editar'),
              ),
              PopupMenuItem<String>(
                value: 'Activar/Desactivar',
                child: Text(user.active! ? 'Desactivar' : 'Activar'),
              ),
              const PopupMenuItem<String>(
                value: 'Restablecer Contraseña',
                child: Text('Restablecer Contraseña'),
              ),
              const PopupMenuItem<String>(
                value: 'Eliminar',
                child: Text('Eliminar', style: TextStyle(color: Colors.red),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadRoles() async {
    _setLoading(isUsers: false, loading: true);
    await fetchDataObject<RoleDTO>(
        uri: uriRoleFindAll,
        classObject: RoleDTO.empty(),
        requestType: RequestTypeEnum.get
    ).then((data) {
      _roleList.clear();
      if (data.isNotEmpty) _roleList.addAll(data.cast<RoleDTO>());
      setState(() {});
    }).onError((error, stackTrace) {
      if (error is ErrorObject) {
        if (error.statusCode == HttpStatus.notFound) {
          _roleList.clear();
          _setLoading(isUsers: false, loading: false);
          return;
        }
        FloatingMessage.show(
            context: context,
            text: error.message ?? 'Error ${error.statusCode}',
            messageTypeEnum: MessageTypeEnum.error
        );
      } else {
        genericError(error!, context, isFloatingMessage: true);
      }
    });
    _setLoading(isUsers: false, loading: false);
  }

  Future<void> _loadTasks() async {
    _setLoading(isUsers: false, loading: true);
    await fetchDataObject<TaskDTO>(
        uri: uriTaskFindAll,
        classObject: TaskDTO.empty(),
        requestType: RequestTypeEnum.get
    ).then((data) {
      _taskList.clear();
      if (data.isNotEmpty) _taskList.addAll(data.cast<TaskDTO>());
    }).onError((error, stackTrace) {
      if (error is ErrorObject) {
        FloatingMessage.show(
            context: context,
            text: error.message ?? 'Error ${error.statusCode}',
            messageTypeEnum: MessageTypeEnum.error
        );
      } else {
        genericError(error!, context, isFloatingMessage: true);
      }
    });
    _setLoading(isUsers: false, loading: false);
  }

  Future<void> _loadUsers() async {
    _setLoading(isUsers: true, loading: true);
    await fetchDataObject<UserDTO>(
        uri: uriUserFindAll,
        classObject: UserDTO.empty(),
        requestType: RequestTypeEnum.get
    ).then((data) {
      _userList.clear();
      if (data.isNotEmpty) _userList.addAll(data.cast<UserDTO>());
      setState(() {});
    }).onError((error, stackTrace) {
      if (error is ErrorObject) {
        FloatingMessage.show(
            context: context,
            text: error.message ?? 'Error ${error.statusCode}',
            messageTypeEnum: MessageTypeEnum.error
        );
      } else {
        genericError(error!, context, isFloatingMessage: true);
      }
    });
    _setLoading(isUsers: true, loading: false);
  }

  Future<void> _addUser() async {
    UserDTO? newUser;
    do {
      // Muestra un diálogo para ingresar los datos del nuevo usuario
      newUser = await showDialog<UserDTO>(
        context: context,
        builder: (BuildContext context) {
          return UserAddDialog(_roleList);
        },
      );

      if (newUser != null) {
        await _saveUser(newUser, isAdd: true);
        _loadUsers();
      }
    } while (newUser != null);
  }

  Future<void> _addRole() async {
    RoleDTO? newRole;
    do {
      newRole = await showDialog<RoleDTO>(
        context: context,
        builder: (BuildContext context) {
          return RoleAddOrTasksUpdateDialog(taskList: _taskList);
        },
      );
      if (newRole != null) {
        if (await _saveRole(newRole, isAdd: true)) _loadRoles();
      }
    } while (newRole != null);
  }

  Future<void> _addTaskToRole(RoleDTO role) async {
    if (!_validateTasks(role.taskList)) return;
    RoleDTO? newRole = await showDialog<RoleDTO>(
      context: context,
      builder: (BuildContext context) {
        return RoleAddOrTasksUpdateDialog(
          role: RoleDTO3(roleId: role.roleId, name: role.name),
          taskList: _getNewTasks(role.taskList)
          );
      },
    );
    if (newRole != null) {
      if (await _saveTasks(newRole)) _loadRoles();
    }
  }

  ///Devuelve true si se pueden agregar tareas al rol.
  ///Si no se puede, muestra un FloatingMessage y retorna false.
  bool _validateTasks(List<TaskDTO>? roleTasks) {
    if (roleTasks == null || roleTasks.isEmpty) return true;

    //No valida si tiene TaskEnum.all
    if (roleTasks.contains(
      TaskDTO(taskId: 1, task: TaskEnum.all, description: null))) {
        FloatingMessage.show(
          context: context,
          text: 'El rol ya tiene todas las tareas asignadas',
          messageTypeEnum: MessageTypeEnum.warning
        );
        return false;
    }

    List<TaskDTO>? newTasks = _getNewTasks(roleTasks);

    //No valida si ya tiene todas las tareas
    if (newTasks!.isEmpty) {
      FloatingMessage.show(
        context: context,
        text: 'El rol ya tiene todas las tareas asignadas manualmente. '
            'Se sugiere seleccionar \'Todas las tareas\' en lugar de la '
            'selección manual.',
        messageTypeEnum: MessageTypeEnum.warning,
        secondsDelay: 7
      );
      return false;
    }

    return true;
  }
  
  ///Devuelve las tareas que estan sin asignar al rol
  List<TaskDTO>? _getNewTasks(List<TaskDTO>? roleTasks) {
    List<TaskDTO> unassigned = [];

    if (roleTasks != null && roleTasks.isNotEmpty) {
      //Obtiene las tareas sin asignar a este rol
      unassigned = _taskList.where((t) => ! roleTasks.contains(t)).toList();
    } else {
      unassigned.addAll(_taskList);
    }

    //Si tiene tareas asignadas, elimina 'Todas las tareas'
    if (unassigned.isNotEmpty && _taskList.length > unassigned.length) {
      unassigned.removeWhere((t) =>
        t == TaskDTO(taskId: 1, task: TaskEnum.all, description: null));
    }
    return unassigned;
  }

  ///isAdd=true: es agregar el usuario. false: es modificar el usuario
  Future<void> _saveUser(UserDTO userDTO, {required bool isAdd}) async {
    _setLoading(isUsers: true, loading: true);

    if (isAdd) {
      // Se crea el usuario para persistir, sin las tareas del rol
      UserDTO newUser = UserDTO(
        name: userDTO.name,
        lastname: userDTO.lastname,
        userName: userDTO.userName,
        pass: userDTO.pass,
        active: true,
        role: RoleDTO(
          roleId: userDTO.role?.roleId,
          name: userDTO.role!.name,
          taskList: null,
        ),
      );
      await _addNewUser(isAdd, newUser);

    } else {
      // Se crea el usuario para persistir un update
      UserDTO2 userDTO2 = UserDTO2(
          userId: userDTO.userId,
          name: userDTO.name,
          lastname: userDTO.lastname,
          role: RoleDTO1(roleId: userDTO.role?.roleId, name: userDTO.role?.name)
      );
      await _updateUser(isAdd, userDTO2);
    }
    _setLoading(isUsers: true, loading: false);
  }

  Future<void> _addNewUser(bool isAdd, UserDTO userDTO) async {
    await fetchDataObject<UserDTO>(
        uri: _getUri(isAdd: isAdd),
        classObject: userDTO,
        requestType: _getRequestType(isAdd: isAdd),
        body: userDTO
    ).then((savedUserId) {
      FloatingMessage.show(
          context: context,
          text: _getMessageSuccess(isAdd: isAdd, isUser: true),
          messageTypeEnum: MessageTypeEnum.info
      );
    }).catchError((error) {
      genericError(error, context, isFloatingMessage: true);
    });
  }

  Future<Null> _updateUser(bool isAdd, UserDTO2 userDTO2) async {
    return await fetchDataObject<UserDTO2>(
        uri: _getUri(isAdd: isAdd),
        classObject: userDTO2,
        requestType: _getRequestType(isAdd: isAdd),
        body: userDTO2
    ).then((savedUserId) {
      FloatingMessage.show(
          context: context,
          text: _getMessageSuccess(isAdd: isAdd, isUser: true),
          messageTypeEnum: MessageTypeEnum.info
      );
    }).catchError((error) {
      genericError(error, context, isFloatingMessage: true);
    });
  }

  Future<bool> _saveTasks(RoleDTO role) async {
    bool ok = true;
    _setLoading(isUsers: false, loading: true);
    await fetchDataObject<EmptyDTO>(
      uri: '$uriRoleAddTasks/${role.roleId}',
      classObject: EmptyDTO.empty(),
      requestType: RequestTypeEnum.put,
      body: role.taskList!.map((t) => toBackendFormat(t.task!)).toList()
    ).then((savedUserId) {
      FloatingMessage.show(
          context: context,
          text: "Tareas actualizadas con éxito",
          messageTypeEnum: MessageTypeEnum.info
      );
    }).catchError((error) {
      ok = false;
      genericError(error, context, isFloatingMessage: true);
    });
    _setLoading(isUsers: false, loading: false);
    return Future.value(ok);
  }


  Future<bool> _saveRole(RoleDTO role, {required bool isAdd}) async {
    bool ok = true;
    _setLoading(isUsers: false, loading: true);
    if (isAdd) {
      ok = await _saveAddRole(role);
    } else {
      ok = await _saveUpdateRole(role);
    }
    _setLoading(isUsers: false, loading: false);
    return Future.value(ok);
  }

  Future<bool> _saveAddRole(RoleDTO role) async {
    bool ok = true;
    RoleDTO2 roleDTO2 = RoleDTO2(
      name: role.name,
      taskList: _buildTasksBackend(role.taskList)
    );
    try {
      await fetchDataObject<RoleDTO2>(
          uri: uriRoleAdd,
          classObject: RoleDTO2.empty(),
          requestType: RequestTypeEnum.post,
          body: roleDTO2
      ).then((value) {
        FloatingMessage.show(
            context: context,
            text: _getMessageSuccess(isAdd: true, isUser: false),
            messageTypeEnum: MessageTypeEnum.info
        );
      });
    } catch(e) {
      if (e is ErrorObject) {
        FloatingMessage.show(
            context: context,
            text: e.message!,
            messageTypeEnum: MessageTypeEnum.warning
        );
      } else {
        genericError(e, context, isFloatingMessage: true);
      }
      ok = false;
    }
    return Future.value(ok);
  }

  List<TaskDTO1>? _buildTasksBackend(List<TaskDTO>? taskList) =>
    taskList?.map((t) => TaskDTO1(task: toBackendFormat(t.task!))).toList();

  Future<bool> _saveUpdateRole(RoleDTO role) async {
    bool ok = true;
    try {
      await fetchDataObject<RoleDTO3>(
          uri: uriRoleUpdate,
          classObject: RoleDTO3.empty(),
          requestType: RequestTypeEnum.patch,
          body: RoleDTO3(roleId: role.roleId, name: role.name),
      ).then((value) {
        FloatingMessage.show(
            context: context,
            text: _getMessageSuccess(isAdd: false, isUser: false),
            messageTypeEnum: MessageTypeEnum.info
        );
      });
    } catch(e) {
      if (e is ErrorObject) {
        FloatingMessage.show(
            context: context,
            text: e.message!,
            messageTypeEnum: MessageTypeEnum.warning
        );
      } else {
        genericError(e, context, isFloatingMessage: true);
      }
      ok = false;
    }
    return Future.value(ok);
  }

  Future<void> _editUser(UserDTO user) async {
    UserDTO? userChanged = await showDialog<UserDTO>(
      context: context,
      builder: (BuildContext context) {
        return UserEditDialog(
          isUser: false,
          user: user,
          roleList: _roleList,
        );
      },
    );
    if (userChanged != null) {
      try {
        await _saveUser(userChanged, isAdd: false);
        _loadUsers();
      } finally {}
    }
  }

  Future<void> _changeRoleName(RoleDTO role) async {
    RoleDTO? roleChanged = await showDialog<RoleDTO>(
      context: context,
      builder: (BuildContext context) {
        return ChangeRoleNameDialog(
            role: RoleDTO(
                roleId: role.roleId,
                name: role.name,
                taskList: []
            )
        );
      },
    );
    if (roleChanged != null && role.name != roleChanged.name) {
      try {
        if (await _saveRole(roleChanged, isAdd: false)) {
          _loadRoles();
          _loadUsers();
        }
      } finally {}
    }
  }

  Future<void> _activateOrDeactivate(UserDTO user) async {
    if (await OpenDialog(
        title: '${user.active! ? 'Desactivar ' : 'Activar '} usuario',
        content:
        'Nombre: ${user.name} ${user.lastname}\n'
            'Rol: ${user.role!.name}\n'
            'Usuario: ${user.userName}\n'
            'Estado: ${user.active! ? 'activo' : 'inactivo'}\n\n'
            '¿Confirma la ${user.active! ? 'desactivación' : 'activación'} del usuario?',
        textButton1: 'Si',
        textButton2: 'No',
        context: context).view() == 1) {
      _setLoading(isUsers: true, loading: true);
      await fetchDataObject<UserDTO>(
          uri: '$uriUserActivate/${user.userId}/${!user.active!}',
          classObject: UserDTO.empty(),
          requestType: RequestTypeEnum.patch
      ).then((value) {
        FloatingMessage.show(
            context: context,
            text: 'Usuario ${user.active! ? 'desactivado' : 'activado'} con éxito',
            messageTypeEnum: MessageTypeEnum.info
        );
        _loadUsers();
      }).onError((error, stackTrace) {
        if (error is ErrorObject) {
          FloatingMessage.show(
              context: context,
              text: error.message!,
              messageTypeEnum: MessageTypeEnum.warning,
              secondsDelay: 8
          );
        } else {
          genericError(error!, context, isFloatingMessage: true);
        }
      });
      _setLoading(isUsers: true, loading: false);
    }
  }

  Future<void> _deleteUser(UserDTO user) async {
    if (await OpenDialog(
        title: 'Confirmación',
        content:
        'Nombre: ${user.name} ${user.lastname}\n'
            'Rol: ${user.role!.name}\n'
            'Usuario: ${user.userName}\n\n'
            '¿Confirma?',
        textButton1: 'Si',
        textButton2: 'No',
        context: context).view() == 1) {
      _setLoading(isUsers: true, loading: true);
      await fetchDataObject<UserDTO>(
          uri: '$uriUserDelete/${user.userId}',
          classObject: UserDTO.empty(),
          requestType: RequestTypeEnum.delete
      ).then((value) {
        FloatingMessage.show(
            context: context,
            text: 'Usuario eliminado con éxito',
            messageTypeEnum: MessageTypeEnum.info
        );
        _loadUsers();
      }).onError((error, stackTrace) {
        if (error is ErrorObject) {
          String msg = 'El usuario está siendo utilizado.\n'
              'No es posible eliminarlo.';
          if (! error.message!.contains('Cannot delete'))  {
            msg = error.message!;
          }
          FloatingMessage.show(
              context: context,
              text: msg,
              messageTypeEnum: MessageTypeEnum.info,
              secondsDelay: 8
          );
        } else {
          genericError(error!, context, isFloatingMessage: true);
        }
      });
      _setLoading(isUsers: true, loading: false);
    }
  }

  Future<void> _deleteRole(RoleDTO role) async {
    if (await OpenDialog(
        title: 'Confirmación',
        content:
        'Eliminar rol ${role.name}.\n'
            '¿Confirma?',
        textButton1: 'Si',
        textButton2: 'No',
        context: context).view() == 1) {
      _setLoading(isUsers: false, loading: true);
      await fetchDataObject<RoleDTO>(
          uri: '$uriRoleDelete/${role.roleId}',
          classObject: RoleDTO.empty(),
          requestType: RequestTypeEnum.delete
      ).then((value) {
        FloatingMessage.show(
            context: context,
            text: 'Rol eliminado con éxito',
            messageTypeEnum: MessageTypeEnum.info
        );
        _loadRoles();
      }).onError((error, stackTrace) {
        if (error is ErrorObject) {
          String msg = 'El rol está siendo utilizado.\n'
              'No es posible eliminarlo.';
          if (! error.message!.contains('Cannot delete'))  {
            msg = error.message!;
          }
          FloatingMessage.show(
              context: context,
              text: msg,
              messageTypeEnum: MessageTypeEnum.info,
              secondsDelay: 8
          );
        } else {
          genericError(error!, context, isFloatingMessage: true);
        }
      });
      _setLoading(isUsers: false, loading: false);
    }
  }

  Future<void> _resetPass(UserDTO user) async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController passController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restablecer Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Usuario: ${user.name} ${user.lastname}'),
              const SizedBox(height: 8.0,),
              Form(
                key: formKey,
                child: CustomTextFormField(
                  controller: passController,
                  label: 'Nueva contraseña',
                  dataType: DataTypeEnum.password,
                  acceptEmpty: false,
                  initialFocus: true,
                  isUnderline: true,
                  viewCharactersCount: true,
                  maxValueForValidation: 10,
                  onEditingComplete: () => _acceptNewPass(
                      user: user,
                      pass: passController.text,
                      form: formKey,
                      context: context
                  ),
                ),
              )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await _acceptNewPass(
                    user: user,
                    pass: passController.text,
                    form: formKey,
                    context: context
                );
              },
              child: const Text('Aceptar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _acceptNewPass(
      { required UserDTO user,
        required String pass,
        required GlobalKey<FormState> form,
        required BuildContext context}) async {

    if (! form.currentState!.validate()) return;
    await _resetPassConfirm(
        user: user,
        newPass: pass,
        context: context
    );
    Navigator.of(context).pop();
  }

  Future<void> _resetPassConfirm({
    required UserDTO user,
    required String newPass,
    required BuildContext context}) async {

    _setLoading(isUsers: true, loading: true);
    await fetchDataObject<UserDTO>(
        uri: '$uriUserChangeCredentials/'
            '${user.userId}/'
            '${user.userName!}/'
            '$newPass',
        classObject: UserDTO.empty(),
        requestType: RequestTypeEnum.put
    ).then((value) {
      FloatingMessage.show(
          context: context,
          text: 'Contraseña restablecida con éxito',
          messageTypeEnum: MessageTypeEnum.info
      );
      _loadUsers();
    }).onError((error, stackTrace) {
      if (error is ErrorObject) {
        FloatingMessage.show(
            context: context,
            text: error.message!,
            messageTypeEnum: MessageTypeEnum.warning,
            secondsDelay: 8
        );
      } else {
        genericError(error!, context, isFloatingMessage: true);
      }
    });
    _setLoading(isUsers: true, loading: false);
  }

  Column _buildSubtitle(UserDTO user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Usuario: ${user.userName}'),
        user.active!
            ? const Text("Activo", style: TextStyle(color: Colors.green))
            : const Text("Inactivo", style: TextStyle(color: Colors.red)),
      ],
    );
  }

  ///isAdd=true: es agregar el usuario. false: es modificar el usuario
  String _getUri({required bool isAdd}) => isAdd ? uriUserAdd : uriUserUpdate;

  ///isAdd=true: es agregar el usuario. false: es modificar el usuario
  RequestTypeEnum _getRequestType({required bool isAdd}) =>
      isAdd ? RequestTypeEnum.post : RequestTypeEnum.patch;

  String _getMessageSuccess({required bool isAdd, required isUser}) {
    if (isAdd) {
      return isUser ? 'Usuario agregado con éxito' : 'Rol agregado con éxito';
    } else {
      return isUser ? 'Usuario modificado con éxito' : 'Rol modificado con éxito';
    }
  }

  void _setLoading({required bool isUsers, required bool loading}) {
    setState(() {
      if (isUsers) {
        _loadingUsers = loading;
      } else {
        _loadingRolesAndTasks = loading;
      }
    });
  }

}
