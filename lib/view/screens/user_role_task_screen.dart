// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/role_dto.dart';
import 'package:novafarma_front/model/DTOs/user_dto.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/enums/request_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/fetch_data_object.dart';
import 'package:novafarma_front/model/globals/constants.dart' show
  uriRoleFindAll, uriRoleAdd, uriUserFindAll, uriUserAdd;
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import '../dialogs/user_dialog.dart';

class UserRoleTaskScreen extends StatefulWidget {

  //final GlobalKey<ScaffoldState> scaffoldKey;
  const UserRoleTaskScreen({super.key}); // required this.scaffoldKey});

  @override
  UserRoleTaskScreenState createState() => UserRoleTaskScreenState();
}

class UserRoleTaskScreenState extends State<UserRoleTaskScreen> {
  final List<RoleDTO> _roleList = [];
  final List<UserDTO> _userList = [];
  bool _loadingRoles = false;
  bool _loadingUsers = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchRoles();
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
                              fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: title == 'Roles' ? _fetchRoles : _fetchUsers,
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
                      return title == 'Roles'
                          ? _buildRoleData(dataList[index])
                          : _buildUserData(dataList[index]);
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
                    onPressed: () {
                      if (title == 'Usuarios') {
                        _addUsers();
                      } else if (title == 'roles') {
                        _addRoles();
                      }
                    },
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Acción para modificar
                    },
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Acción para eliminar
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

  Widget _buildRoleData(RoleDTO role) {
    return ListTile(
      title: Text(role.name),
    );
  }

  Widget _buildUserData(UserDTO user) {
    return ListTile(
      title: Text('${user.name} ${user.lastname} (${user.role.name})'),
      subtitle: user.active!
          ? const Text("Activo", style: TextStyle(color: Colors.green))
          : const Text("Inactivo", style: TextStyle(color: Colors.red))
    );
  }

  Future<void> _fetchRoles() async {
    setState(() {
      _loadingRoles = true;
    });

    try {
      fetchDataObject<RoleDTO>(
          uri: uriRoleFindAll,
          classObject: RoleDTO.empty(),
          requestType: RequestTypeEnum.get)
          .then((data) => {
        setState(() {
          _roleList.clear();
          _roleList.addAll(data.cast<RoleDTO>().map((e) =>
              RoleDTO(roleId: e.roleId, name: e.name)));
          _loadingRoles = false;
        })
      });
    } catch (e) {
      setState(() {
        _loadingRoles = false;
      });
      FloatingMessage.show(
          context: context,
          text: "Error de conexión",
          messageTypeEnum: MessageTypeEnum.error
      );
      /*floatingMessage(
          context: context,
          text: "Error de conexión",
          messageTypeEnum: MessageTypeEnum.error
      );*/
    }
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _loadingUsers = true;
    });

    try {
      fetchDataObject<UserDTO>(
          uri: uriUserFindAll,
          classObject: UserDTO.empty(),
          requestType: RequestTypeEnum.get
      ).then((data) => {
        setState(() {
          _userList.clear();
          if (data.isNotEmpty) {
            _userList.addAll(data.cast<UserDTO>().map((e) =>
                UserDTO(
                  userId: e.userId,
                  name: e.name,
                  lastname: e.lastname,
                  active: e.active,
                  role: e.role,
                )
            ));
          }
          _loadingUsers = false;
        })
      }).onError((error, stackTrace) {
        FloatingMessage.show(
            context: context,
            text: "Error de conexión",
            messageTypeEnum: MessageTypeEnum.error
        );
        /*floatingMessage(
            context: context,
            text: "Error de conexión",
            messageTypeEnum: MessageTypeEnum.error
        );*/
        setState(() {
          _loadingUsers = false;
        });
        return <void>{};
      });

    } catch (e) {
      setState(() {
        _loadingUsers = false;
      });
      FloatingMessage.show(
          context: context,
          text: "Error: $e",
          messageTypeEnum: MessageTypeEnum.error
      );
      /*floatingMessage(
          context: context,
          text: "Error: $e",
          messageTypeEnum: MessageTypeEnum.error
      );*/
    }
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
              _fetchUsers();
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



}
