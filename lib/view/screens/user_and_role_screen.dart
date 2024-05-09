import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/RoleDTO.dart';
import 'package:novafarma_front/model/globals/requests/fetch_data_object.dart';
import 'package:novafarma_front/model/globals/constants.dart' show
  uriRoleFindAll;

class UserAndRoleScreen extends StatefulWidget {
  const UserAndRoleScreen({super.key});

  @override
  _UserAndRoleScreenState createState() => _UserAndRoleScreenState();
}

class _UserAndRoleScreenState extends State<UserAndRoleScreen> {
  late List<RoleDTO> _roles = List.empty();
  bool _loadingRoles = false;

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    setState(() {
      _loadingRoles = true;
    });

    try {
      List<RoleDTO> roles = (await fetchDataObject<RoleDTO>(
        uri: uriRoleFindAll,
        classObject: RoleDTO.empty(),
      )) as List<RoleDTO>;

      setState(() {
        _roles = roles;
        _loadingRoles = false;
      });
    } catch (e) {
      setState(() {
        _loadingRoles = false;
      });
      // Manejar el error
    }
  }

  Widget buildContainer(String title, IconData icon) {
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
                color: title == 'Roles' ? Colors.blue : Colors.green, // Color de fondo del título
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: Colors.white), // Icono del título
                        const SizedBox(width: 8), // Espacio entre el icono y el texto
                        Text(
                          title, // Título del contenedor
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _fetchRoles,
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10), // Espacio entre el título y la lista de elementos
            _loadingRoles
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_roles[index].name),
                    // Otros detalles del rol, si los hay
                  );
                },
              ),
            ),
            Container(
              height: 40, // Altura de la barra de botones
              decoration: BoxDecoration(
                color: title == 'Roles' ? Colors.blue : Colors.green, // Color de la barra de botones
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildContainer('Roles', Icons.group),
        buildContainer('Usuarios', Icons.person),
      ],
    );
  }
}
