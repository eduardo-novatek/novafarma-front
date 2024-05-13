import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/data_types_enum.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';

import '../../model/DTOs/role_dto.dart';
import '../../model/DTOs/user_dto.dart';

class AddUserOverlay extends StatefulWidget {

  final List<RoleDTO> roleList;

  const AddUserOverlay(this.roleList);

  @override
  _AddUserOverlayState createState() => _AddUserOverlayState();
}

class _AddUserOverlayState extends State<AddUserOverlay> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar usuario'),

      content: Column(

        mainAxisSize: MainAxisSize.min,

        children: <Widget>[
          CreateTextFormField(
            controller: nameController,
            label: 'Nombre',
            dataType: DataTypesEnum.text,
            maxValueForValidation: 25,
          ),

          CreateTextFormField(
            controller: lastNameController,
            label: 'Apellido',
            dataType: DataTypesEnum.text,
            maxValueForValidation: 25,
          ),

          CreateTextFormField(
            controller: userNameController,
            label: 'Nombre de usuario',
            dataType: DataTypesEnum.text,
            maxValueForValidation: 10,
          ),

          CreateTextFormField(
            controller: passController,
            label: 'Contraseña',
            dataType: DataTypesEnum.password,
            maxValueForValidation: 10,
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
              name: nameController.text,
              lastname: lastNameController.text,
              userName: userNameController.text,
              pass: passController.text,
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

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    _overlayEntry = _createOverlayEntry();
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => const Center(
        child: AddUserOverlay([]), // Aquí deberías pasar la lista de roles
      ),
    );
  }

  void _showOverlay() {
    Overlay.of(context)!.insert(_overlayEntry);
  }

  void _hideOverlay() {
    _overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _showOverlay();
      },
      child: const Text('Mostrar diálogo'),
    );
  }
}
