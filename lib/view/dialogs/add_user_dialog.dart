import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/data_types_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/requests/user_name_exist.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/custom_dropdown.dart';

import '../../model/DTOs/role_dto.dart';
import '../../model/DTOs/user_dto.dart';
import '../../model/globals/tools/floating_message.dart';

class AddUserDialog extends StatefulWidget {

  //final GlobalKey<ScaffoldState> scaffoldKey;
  final List<RoleDTO> roleList;

  const AddUserDialog(this.roleList, {super.key}); //, required this.scaffoldKey});

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();

  String selectedRole = defaultTextFromDropdownMenu;
  ThemeData themeData = ThemeData();

  @override
  void initState() {
    super.initState();
    widget.roleList.insert(
        0,
        RoleDTO(isFirst: true, roleId: null, name: defaultTextFromDropdownMenu)
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.roleList[0].isFirst == true ? widget.roleList.removeAt(0) : null;
    _nameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _passController.dispose();
    //
    _nameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _userNameFocusNode.dispose();
    _passFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar usuario'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Container(
              constraints: const BoxConstraints(minWidth:300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CreateTextFormField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    label: 'Nombre',
                    dataType: DataTypesEnum.text,
                    maxValueForValidation: 25,
                    textForValidation: 'El nombre es requerido',
                  ),
                  const SizedBox(height: 10.0,),

                  CreateTextFormField(
                    controller: _lastNameController,
                    focusNode: _lastNameFocusNode,
                    label: 'Apellido',
                    dataType: DataTypesEnum.text,
                    maxValueForValidation: 25,
                    textForValidation: 'El apellido es requerido',
                  ),
                  const SizedBox(height: 10.0,),

                  CreateTextFormField(
                    controller: _userNameController,
                    focusNode: _userNameFocusNode,
                    label: 'Nombre de usuario',
                    dataType: DataTypesEnum.text,
                    maxValueForValidation: 10,
                    textForValidation: 'El nombre de usuario es requerido',
                  ),
                  const SizedBox(height: 10.0,),

                  CreateTextFormField(
                    controller: _passController,
                    focusNode: _passFocusNode,
                    label: 'Contraseña',
                    dataType: DataTypesEnum.password,
                    maxValueForValidation: 10,
                    textForValidation: 'La contraseña es requerida',
                  ),
                  const SizedBox(height: 10.0,),

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
                        callback: (role) {
                          selectedRole = role!.name;
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
        ),
      ),

      actions: <Widget>[
        ElevatedButton(
          child: const Text('Aceptar'),
          onPressed: () async {
            if (await _validatedForm(
              userName: _userNameController.text,
              userNameFocusNode: _userNameFocusNode,)) {

              if (!context.mounted) return;

              UserDTO newUser = UserDTO(
                name: _nameController.text,
                lastname: _lastNameController.text,
                userName: _userNameController.text,
                pass: _passController.text,
                role: widget.roleList.firstWhere(
                        (role) => role.name == selectedRole),
              );

              // Cierra el diálogo y devuelve el nuevo usuario
              Navigator.of(context).pop(newUser);
            }
          }
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context)
                .pop(); // Cierra el diálogo sin agregar usuario
          },
        ),
      ],
    );

  }

  Future<bool> _validatedForm({
  required String userName, required FocusNode userNameFocusNode,}) async {

    if (!_formKey.currentState!.validate()) return false;

    try {
      if (await existUserName(userName: userName)) {
        if (context.mounted) {
          floatingMessage(
              context: context,
              text: 'Usuario ya registrado: $userName',
              messageTypeEnum: MessageTypeEnum.warning
          );
          //floatingMessage(widget.scaffoldKey.currentContext!, "Usuario ya registrado");
          _userNameFocusNode.requestFocus();
        }
        return false;
      }

      return true;

    } catch (e) {
      floatingMessage(
          context: context,
          text: "Error de conexión",
        messageTypeEnum: MessageTypeEnum.error
      );
      return false;
    }

  }


}


