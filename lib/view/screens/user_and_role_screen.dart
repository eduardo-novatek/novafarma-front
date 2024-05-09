import 'package:flutter/material.dart';

class UserAndRoleScreen extends StatefulWidget {
  const UserAndRoleScreen({super.key});

  @override
  State<UserAndRoleScreen> createState() => _UserAndRoleScreenState();
}

class _UserAndRoleScreenState extends State<UserAndRoleScreen> {
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
                      onPressed: () {
                        // Acción para refrescar
                      },
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10), // Espacio entre el título y la lista de elementos
            // Aquí puedes agregar la lista de elementos para el contenedor
            Expanded(child: Container()), // Espacio entre la lista de elementos y los botones
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
