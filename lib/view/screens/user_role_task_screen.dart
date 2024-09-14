// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/role_dto.dart';
import 'package:novafarma_front/model/DTOs/role_dto1.dart';
import 'package:novafarma_front/model/DTOs/user_dto.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/enums/request_type_enum.dart';
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/globals/tools/fetch_data_object.dart';
import 'package:novafarma_front/model/globals/constants.dart' show uriRoleAdd, uriRoleFindAll, uriUserAdd, uriUserFindAll, uriUserUpdate;
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/objects/error_object.dart';
import 'package:novafarma_front/view/dialogs/role_add_dialog.dart';
import 'package:novafarma_front/view/dialogs/user_edit_dialog.dart';
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
    bool _loadingUsers = false;
    bool _loadingRoles = false;
    int? _hoveredUserIndex;  // Índice de hover para el panel de usuarios
    int? _hoveredRoleIndex;  // Índice de hover para el panel de roles

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadRoles();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildContainer('Usuarios', Icons.person, _userList, _loadingUsers),
        _buildContainer('Roles', Icons.group, _roleList, _loadingRoles),
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
              color: title == 'Roles' ? Colors.blue : Colors.green,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: title == 'Roles' ? _loadRoles : _loadUsers,
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
        color: title == 'Roles' ? Colors.blue : Colors.green,
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
              } else if (title == 'roles') {
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
          _hoveredRoleIndex = index;  // Establece el índice del elemento en hover para roles
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredRoleIndex = null;  // Desactiva el hover
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _hoveredRoleIndex == index ? Colors.grey.shade300 : Colors.white,  // Cambia de color en hover
          border: Border(
            left: BorderSide(
              color: _hoveredRoleIndex == index ? Colors.blue : Colors.transparent,  // Cambia de color el borde en hover
              width: 5,
            ),
          ),
        ),
        child: ListTile(
          title: Text(role.name),
          trailing: PopupMenuButton<String>(
            tooltip: '',
            onSelected: (value) {
              switch (value) {
                case 'Editar':
                // Lógica para editar rol
                  break;
                case 'Eliminar':
                // Lógica para eliminar rol
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Editar',
                child: Text('Editar'),
              ),
              const PopupMenuItem<String>(
                value: 'Eliminar',
                child: Text('Eliminar'),
              ),
            ],
          ),
        ),
      ),
    );
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
                case 'Reestablecer Contraseña':
                  break;
                case 'Eliminar':
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
                child: Text(user.active! ? 'Inactivar' : 'Activar'),
              ),
              const PopupMenuItem<String>(
                value: 'Reestablecer Contraseña',
                child: Text('Reestablecer Contraseña'),
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
    setState(() {
      _loadingRoles = true;
    });
    fetchDataObject<RoleDTO>(
      uri: uriRoleFindAll,
      classObject: RoleDTO.empty(),
      requestType: RequestTypeEnum.get
    ).then((data) {
      _roleList.clear();
      _roleList.addAll(data.cast<RoleDTO>().map((e) =>
          e.fromJson(e.toJson())));
       setState(() {
       _loadingRoles = false;
       });
    }).onError((error, stackTrace) {
      setState(() {
        _loadingRoles = false;
      });
      if (error is ErrorObject) {
        FloatingMessage.show(
            context: context,
            text: error.message ?? 'Error ${error.statusCode}',
            messageTypeEnum: MessageTypeEnum.error
        );
      } else {
        genericError(error!, context);
      }
    });
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loadingUsers = true;
    });
    fetchDataObject<UserDTO>(
        uri: uriUserFindAll,
        classObject: UserDTO.empty(),
        requestType: RequestTypeEnum.get
    ).then((data) {
      _userList.clear();
      if (data.isNotEmpty) {
        _userList.addAll(data.cast<UserDTO>().map(
                (e) => e.fromJson(e.toJson())
        ));
        setState(() {
          _loadingUsers = false;
        });
      }
    }).onError((error, stackTrace) {
      setState(() {
        _loadingUsers = false;
      });
      if (error is ErrorObject) {
        FloatingMessage.show(
            context: context,
            text: error.message ?? 'Error ${error.statusCode}',
            messageTypeEnum: MessageTypeEnum.error
        );
      } else {
        genericError(error!, context);
      }
    });
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
    RoleDTO1? newRole;
    do {
      // Muestra un diálogo para ingresar los datos del nuevo usuario
      newRole = await showDialog<RoleDTO1>(
        context: context,
        builder: (BuildContext context) {
          return RoleAddDialog();
        },
      );

      if (newRole != null) {
        await _saveRole(newRole, isAdd: true);
        _loadUsers();
      }
    } while (newRole != null);
  }

  ///isAdd=true: es agregar el usuario. false: es modificar el usuario
  Future<void> _saveUser(UserDTO user, {required bool isAdd}) async {
    _setLoading(isUsers: true, loading: true);
    await fetchDataObject<UserDTO>(
        uri: _getUri(isAdd: isAdd),
        classObject: user,
        requestType: _getRequestType(isAdd: isAdd),
        body: user
    ).then((savedUserId) {
      FloatingMessage.show(
          context: context,
          text: _getMessageSuccess(isAdd: isAdd),
          messageTypeEnum: MessageTypeEnum.info
      );
      // Si está la opcion "Seleccione...", la elimina de la lista
      if (_roleList[0].isFirst! == true) _roleList.removeAt(0);
    }).catchError((error) {
      genericError(error, context, isFloatingMessage: true);
    });
    _setLoading(isUsers: true, loading: false);
  }

  Future<void> _saveRole(RoleDTO1 role, {required bool isAdd}) async {
    _setLoading(isUsers: false, loading: true);
    try {
      await fetchDataObject<RoleDTO1>(
        uri: uriRoleAdd,
        classObject: RoleDTO1.empty(),
        requestType: RequestTypeEnum.post,
        body: role
      );
    } catch(e) {
      genericError(e, context, isFloatingMessage: true);
    }
    _setLoading(isUsers: false, loading: false);
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

  void _activateOrDeactivate(UserDTO user) {

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

  String _getMessageSuccess({required bool isAdd}) =>
    isAdd ? 'Usuario agregado con éxito' : 'Usuario modificado con éxito';

  void _setLoading({required bool isUsers, required bool loading}) {
    setState(() {
      if (isUsers) {
        _loadingUsers = loading;
      } else {
        _loadingRoles = loading;
      }
    });
  }

}
