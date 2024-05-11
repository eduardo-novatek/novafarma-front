import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/role_dto.dart';
import 'package:novafarma_front/model/DTOs/user_dto.dart';
import 'package:novafarma_front/model/enums/request_type_enum.dart';
import 'package:novafarma_front/model/globals/requests/fetch_data_object.dart';
import 'package:novafarma_front/model/globals/constants.dart' show
  uriRoleFindAll, uriUserFindAll;
import 'package:novafarma_front/model/globals/tools/floating_message.dart';

class UserAndRoleScreen extends StatefulWidget {
  const UserAndRoleScreen({super.key});

  @override
  _UserAndRoleScreenState createState() => _UserAndRoleScreenState();
}

class _UserAndRoleScreenState extends State<UserAndRoleScreen> {
  final List<RoleDTO> _roleList = [];
  final List<UserDTO> _userList = [];
  bool _loadingRoles = false;
  bool _loadingUsers = false;

  @override
  void initState() {
    super.initState();
    _fetchRoles();
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildContainer('Roles', Icons.group, _roleList, _loadingRoles),
        buildContainer('Usuarios', Icons.person, _userList, _loadingUsers),
      ],
    );
  }

  Widget buildContainer(
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
                      onPressed: title == 'Roles'
                          ? _fetchRoles
                          : _fetchUsers,
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
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
                          ? buildRoleData(dataList[index])
                          : buildUserData(dataList[index]);
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
                    onPressed: () {
                      // Acción para agregar
                    },
                    icon: const Icon(Icons.add),
                    color: Colors.white,
                  ),
                  IconButton(
                    onPressed: () {
                      // Acción para modificar
                    },
                    icon: const Icon(Icons.edit),
                    color: Colors.white,
                  ),
                  IconButton(
                    onPressed: () {
                      // Acción para eliminar
                    },
                    icon: const Icon(Icons.delete),
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

  Widget buildRoleData(RoleDTO role) {
    return Text(role.name);
  }

  Widget buildUserData(UserDTO user) {
    return ListTile(
      title: Text('${user.name} ${user.lastname}'),
      subtitle: Text('Activo: ${user.active ? "Si" : "No"}'
          'Rol: ${user.role.name}'),
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
      floatingMessage(context, "Error de conexión");
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
          requestType: RequestTypeEnum.get)
          .then((data) => {
        setState(() {
          _userList.clear();
          _userList.addAll(data.cast<UserDTO>().map((e) => UserDTO(
            userId: e.userId,
            name: e.name,
            lastname: e.lastname,
            active: e.active,
            role: e.role,
          )));
          _loadingUsers = false;
        })
      });
    } catch (e) {
      setState(() {
        _loadingUsers = false;
      });
      floatingMessage(context, "Error de conexión");
    }
  }
}
