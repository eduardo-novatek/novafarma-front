import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/data_types_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/custom_dropdown.dart';

import '../../model/DTOs/role_dto.dart';
import '../../model/DTOs/user_dto.dart';

class AddUserDialog extends StatefulWidget {

  final List<RoleDTO> roleList;

  const AddUserDialog(this.roleList, {super.key});

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  String? selectedRole;

  @override
  void initState() {
    super.initState();
    widget.roleList.insert(
        0,
        RoleDTO(isFirst: true, roleId: null, name: defaultTextFromDropdownMenu)
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = ThemeData();

    return AlertDialog(
      title: const Text('Agregar usuario'),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: Column(
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

              const SizedBox(height: 25.0,),

              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text("Rol:"),
                  ),
                  CustomDropdown<RoleDTO>(
                    themeData: themeData,
                    modelList: widget.roleList,
                    model: widget.roleList[0],
                    callback: (selectedRolName) {

                    },
                  ),
                ],
              )


              /*
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
              ),*/
            ],
          ),
        ),
      ),

      actions: <Widget>[
        ElevatedButton(
          child: const Text('Aceptar'),
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
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el diálogo sin agregar usuario
          },
        ),
      ],
    );
  }
}
