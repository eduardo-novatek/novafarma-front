// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/role_dto.dart';
import 'package:novafarma_front/model/DTOs/user_dto.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/enums/request_type_enum.dart';
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/globals/tools/fetch_data_object.dart';
import 'package:novafarma_front/model/globals/constants.dart' show
  uriRoleFindAll, uriRoleAdd, uriUserFindAll, uriUserAdd;
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/objects/error_object.dart';
import '../dialogs/user_dialog.dart';

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
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Colors.black54),
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            loading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                  child: ListView.builder(
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      return title == 'Usuarios'
                          ? _buildUserData(dataList[index], index)
                          : _buildRoleData(dataList[index], index);
                    },
                  ),
                ),
            Container(
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
                        _addUsers();
                      } else if (title == 'roles') {
                        _addRoles();
                      }
                    },
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
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
          title: Text('${user.name} ${user.lastname} (${user.role.name})'),
          subtitle: user.active!
              ? const Text("Activo", style: TextStyle(color: Colors.green))
              : const Text("Inactivo", style: TextStyle(color: Colors.red)),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'Editar':
                  _editUser(user);
                  break;
                case 'Activar':
                // Lógica para activar usuario
                  break;
                case 'Reestablecer Contraseña':
                // Lógica para reestablecer contraseña
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Editar',
                child: Text('Editar'),
              ),
              const PopupMenuItem<String>(
                value: 'Activar',
                child: Text('Activar'),
              ),
              const PopupMenuItem<String>(
                value: 'Reestablecer Contraseña',
                child: Text('Reestablecer Contraseña'),
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

  Future<void> _addUsers() async {
    UserDTO? newUser;
    do {
        // Muestra un diálogo para ingresar los datos del nuevo usuario
        newUser = await showDialog<UserDTO>(
          context: context,
          builder: (BuildContext context) {
            return AddUserDialog(_roleList);
          },
        );

        if (newUser != null) {
          try {
            fetchDataObject(
                uri: uriUserAdd,
                classObject: newUser,
                requestType: RequestTypeEnum.post,
                body: newUser
            ).then((newUserId) {
              FloatingMessage.show(
                  context: context,
                  text: "Usuario agregado con éxito",
                  messageTypeEnum: MessageTypeEnum.info
              );
              /*floatingMessage(
                  context: context,
                  text: "Usuario agregado con éxito",
                  messageTypeEnum: MessageTypeEnum.info
              );*/
              // Si está la opcion "Seleccione...", la elimina de la lista
              if (_roleList[0].isFirst! == true) _roleList.removeAt(0);
              // Actualiza la lista de usuarios
              _loadUsers();
            });
          } catch (e) {
            FloatingMessage.show(
                context: context,
                text: 'Error: $e',
                messageTypeEnum: MessageTypeEnum.error
            );
            /*floatingMessage(
                context: context,
                text: 'Error: $e',
                messageTypeEnum: MessageTypeEnum.error
            );*/
          }
        }
    } while (newUser != null);
  }

  Future<void> _addRoles() async {
    try {
      fetchDataObject(
        uri: uriRoleAdd,
        classObject: RoleDTO.empty(),
        requestType: RequestTypeEnum.post,
      );
      //@2

    } catch(e) {
      FloatingMessage.show(
          context: context,
          text: 'Error: $e',
          messageTypeEnum: MessageTypeEnum.error
      );
      /*floatingMessage(
          context: context,
          text: 'Error: $e',
          messageTypeEnum: MessageTypeEnum.error
      );*/
    }

  }

  void _editUser(UserDTO user) {


  }

}
