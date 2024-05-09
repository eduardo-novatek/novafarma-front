import 'package:flutter/material.dart';

class UserAndRoleScreen extends StatefulWidget {
  const UserAndRoleScreen({super.key});

  @override
  State<UserAndRoleScreen> createState() => _UserAndRoleScreenState();
}

class _UserAndRoleScreenState extends State<UserAndRoleScreen> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
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
                    color: Colors.blue, // Color de fondo del título
                    padding: EdgeInsets.all(8.0),
                    child: const Text(
                      'Roles', // Título del contenedor 1
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10), // Espacio entre el título y la lista de elementos
                // Aquí puedes agregar la lista de elementos para el contenedor 1
              ],
            ),
          ),
        ),

        Expanded(
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
                    color: Colors.green, // Color de fondo del título
                    padding: EdgeInsets.all(8.0),
                    child: const Text(
                      'Usuarios', // Título del contenedor 2
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10), // Espacio entre el título y la lista de elementos
                // Aquí puedes agregar la lista de elementos para el contenedor 2
              ],
            ),
          ),
        ),
      ],
    );
  }
}
