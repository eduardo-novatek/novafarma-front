// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/requests/user_name_exist.dart';
import 'package:novafarma_front/model/globals/tools/custom_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/custom_dropdown.dart';

import '../../model/DTOs/role_dto.dart';
import '../../model/DTOs/user_dto.dart';
import '../../model/globals/tools/floating_message.dart';

class UserAddDialog extends StatefulWidget {

  final List<RoleDTO> roleList;

  const UserAddDialog(this.roleList, {super.key});

  @override
  State<UserAddDialog> createState() => _UserAddDialogState();
}

class _UserAddDialogState extends State<UserAddDialog> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();

  String _selectedRole = defaultFirstOption;
  final List<String> roles = [];

  @override
  void initState() {
    super.initState();
    roles.add(defaultFirstOption);
    roles.addAll(widget.roleList.map((e) => e.name));
  }

  @override
  void dispose() {
    super.dispose();
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
                  CustomTextFormField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    label: 'Nombre',
                    initialFocus: true,
                    dataType: DataTypeEnum.text,
                    maxValueForValidation: 25,
                    textForValidation: 'El nombre es requerido',
                    onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(_lastNameFocusNode),
                  ),
                  const SizedBox(height: 10.0,),

                  CustomTextFormField(
                    controller: _lastNameController,
                    focusNode: _lastNameFocusNode,
                    label: 'Apellido',
                    dataType: DataTypeEnum.text,
                    maxValueForValidation: 25,
                    textForValidation: 'El apellido es requerido',
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_userNameFocusNode),
                  ),
                  const SizedBox(height: 10.0,),

                  CustomTextFormField(
                    controller: _userNameController,
                    focusNode: _userNameFocusNode,
                    label: 'Nombre de usuario',
                    dataType: DataTypeEnum.text,
                    maxValueForValidation: 10,
                    textForValidation: 'El nombre de usuario es requerido',
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_passFocusNode),
                  ),
                  const SizedBox(height: 10.0,),

                  CustomTextFormField(
                    controller: _passController,
                    focusNode: _passFocusNode,
                    label: 'Contraseña',
                    dataType: DataTypeEnum.password,
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
                      CustomDropdown<String>(
                        themeData: ThemeData(),
                        optionList: roles,
                        selectedOption: _selectedRole,
                        isSelected: true,
                        callback: (role) {
                          setState(() {
                            _selectedRole = role!;
                          });
                        },
                      ),
                    ],
                  )
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
            if (await _validatedForm()) {
              if (!context.mounted) return;
              UserDTO newUser = UserDTO(
                name: _nameController.text,
                lastname: _lastNameController.text,
                userName: _userNameController.text,
                pass: _passController.text,
                role: widget.roleList.firstWhere(
                  (role) => role.name == _selectedRole
                ),
              );
              Navigator.of(context).pop(newUser); // Cierra el diálogo y devuelve el nuevo usuario
            }
          }
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () async {
            Navigator.of(context).pop(); // Cierra el diálogo sin agregar usuario
          },
        ),
      ],
    );

  }

  Future<bool> _validatedForm() async {

    if(_userNameIsSuperAdmin()) {
      _userNameController.value = TextEditingValue.empty;
      _passController.value = TextEditingValue.empty;
    }
    if (!_formKey.currentState!.validate()) return Future.value(false);

    try {
      if (await userNameExist(userName: _userNameController.text.trim())) {
        if (context.mounted) {
          FloatingMessage.show(
              context: context,
              text: 'Usuario ya registrado: ${_userNameController.text.trim()}',
              messageTypeEnum: MessageTypeEnum.warning
          );
          _userNameFocusNode.requestFocus();
        }
        return Future.value(false);
      }

      if (_selectedRole == defaultFirstOption) {
        if (context.mounted) {
          FloatingMessage.show(
              context: context,
              text: 'Por favor, seleccione el rol',
              messageTypeEnum: MessageTypeEnum.warning
          );
        }
        return Future.value(false);
      }
    } catch (e) {
      FloatingMessage.show(
          context: context,
          text: "Error de conexión",
          messageTypeEnum: MessageTypeEnum.error
      );
      return Future.value(false);
    }
    return Future.value(true);  // Validacion correcta
  }

  bool _userNameIsSuperAdmin() =>
    _userNameController.text.trim().toUpperCase() == superAdminUser.toUpperCase();

}


