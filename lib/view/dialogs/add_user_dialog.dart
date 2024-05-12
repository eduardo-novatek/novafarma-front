import 'package:flutter/material.dart';

import '../../model/DTOs/role_dto.dart';
import '../../model/DTOs/user_dto.dart';

class AddUserDialog extends StatefulWidget {
  final List<RoleDTO> roleList;

  const AddUserDialog(this.roleList, {Key? key}) : super(key: key);

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar usuario'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const TextField(
            decoration: InputDecoration(labelText: 'Nombre'),
          ),
          const TextField(
            decoration: InputDecoration(labelText: 'Apellido'),
          ),
          const TextField(
            decoration: InputDecoration(labelText: 'Nombre de usuario'),
          ),
          const TextField(
            decoration: InputDecoration(labelText: 'Contraseña'),
          ),
          DropdownButtonFormField(
            value: selectedRole,
            onChanged: (value) {
              setState(() {
                selectedRole = value!;
              });
            },
            items: widget.roleList.map((role) {
              return DropdownMenuItem(
                value: role.name,
                child: Text(role.name),
              );
            }).toList(),
            decoration: const InputDecoration(
              labelText: 'Rol',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el diálogo sin agregar usuario
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            UserDTO newUser = UserDTO(
              name: 'Nombre', // Reemplazar con el valor del TextField
              lastname: 'Apellido', // Reemplazar con el valor del TextField
              userName: 'userName',
              pass: 'pass',
              role: widget.roleList.firstWhere((role) => role.name == selectedRole),
            );
            Navigator.of(context).pop(newUser); // Cierra el diálogo y devuelve el nuevo usuario
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
