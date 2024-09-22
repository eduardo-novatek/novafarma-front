// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/globals/requests/user_name_exist.dart';
import 'package:novafarma_front/model/globals/tools/custom_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/custom_dropdown.dart';

import '../../model/DTOs/role_dto.dart';
import '../../model/DTOs/user_dto.dart';
import '../../model/globals/tools/floating_message.dart';

///Permite la edicion del usuario. Si lo hace el mismo usuario, permite cambiar
///nombre, apellido, username y pass. Si lo hace el SuperAdmin, permite cambiar
///nombre, apellido y rol.
class UserEditDialog extends StatefulWidget {
  final bool isUser; //true si es el usuario quien hace la edicion. False si es el SuperAdmin.
  final UserDTO user;
  final List<RoleDTO> roleList;

  const UserEditDialog({
    required this.roleList,
    required this.isUser,
    required this.user,
    super.key
  });

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {

  final _formKey = GlobalKey<FormState>();
  final ThemeData _themeData = ThemeData();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _lastnameFocusNode = FocusNode();
  final FocusNode _userNameFocusNode = FocusNode();

  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    if (!widget.roleList[0].isFirst!) {
      widget.roleList.insert(
          0,
          RoleDTO(
            isFirst: true,
            roleId: null,
            name: defaultFirstOption,
            taskList: []
          )
      );
    }
    _nameController.value = TextEditingValue(text: widget.user.name!);
    _lastnameController.value = TextEditingValue(text: widget.user.lastname!);
    _userNameController.value = TextEditingValue(text: widget.user.userName!);
    _selectedRole = widget.user.role!.name;
  }

  @override
  void dispose() {
    super.dispose();
    widget.roleList[0].isFirst == true ? widget.roleList.removeAt(0) : null;
    _nameController.dispose();
    _lastnameController.dispose();
    _userNameController.dispose();
    //
    _nameFocusNode.dispose();
    _lastnameFocusNode.dispose();
    _userNameFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar usuario'),
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
                      FocusScope.of(context).requestFocus(_lastnameFocusNode),
                  ),
                  const SizedBox(height: 10.0,),

                  CustomTextFormField(
                    controller: _lastnameController,
                    focusNode: _lastnameFocusNode,
                    label: 'Apellido',
                    dataType: DataTypeEnum.text,
                    maxValueForValidation: 25,
                    textForValidation: 'El apellido es requerido',
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_userNameFocusNode),
                  ),
                  const SizedBox(height: 10.0,),

                  if (widget.isUser)
                    Row(
                      children: [
                        CustomTextFormField(
                          controller: _userNameController,
                          focusNode: _userNameFocusNode,
                          label: 'Nombre de usuario',
                          dataType: DataTypeEnum.text,
                          maxValueForValidation: 10,
                          textForValidation: 'El nombre de usuario es requerido',
                        ),
                        const SizedBox(height: 10.0,),
                      ],
                    ),
                  if (!widget.isUser) //Si es SuperAdmin
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text("Rol:"),
                        ),
                        CustomDropdown<RoleDTO>(
                          themeData: _themeData,
                          optionList: widget.roleList,
                          selectedOption: widget.roleList[_getSelectedRole()],
                          isSelected: true,
                          callback: (role) {
                            setState(() {
                              _selectedRole = role!.name;
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
            if (await _validatedForm(userName: _userNameController.text)) {
              if (!context.mounted) return;
              UserDTO userUpdated = UserDTO(
                userId: widget.user.userId,
                name: _nameController.text.trim(),
                lastname: _lastnameController.text.trim(),
                userName: _userNameController.text,
                active: widget.user.active,
                changeCredentials: widget.user.changeCredentials,
                role: widget.roleList.firstWhere(
                        (role) => role.name == _selectedRole),
              );
              // Cierra el diálogo y devuelve el usuario actualizado
              Navigator.of(context).pop(userUpdated);
            }
          }
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop(null); // Cierra el diálogo sin agregar usuario
          },
        ),
      ],
    );
  }

  Future<bool> _validatedForm({required String userName}) async {
    if (_userNameIsSuperAdmin()) _userNameController.value = TextEditingValue.empty;
    if (!_formKey.currentState!.validate()) return false;

    try {
      if (!_sameUsername()) {
        if (await userNameExist(userName: userName)) {
          if (context.mounted) {
            FloatingMessage.show(
                context: context,
                text: 'Usuario ya registrado: $userName',
                messageTypeEnum: MessageTypeEnum.warning
            );
            _userNameFocusNode.requestFocus();
          }
          return false;
        }
      }
      if (_selectedRole == defaultFirstOption) {
        if (context.mounted) {
          FloatingMessage.show(
              context: context,
              text: 'Por favor, seleccione el rol',
              messageTypeEnum: MessageTypeEnum.warning
          );
        }
        return false;
      }
    } catch (e) {
      genericError(e, isFloatingMessage: true, context);
      return false;
    }
    return true;  // Validacion correcta
  }

  ///true si el nombre de usuario ingresado es el mismo que el seleccionado
  ///siempre que sea un usuario quien esté editando
  bool _sameUsername() => widget.user.userName == _userNameController.text.trim();

  int _getSelectedRole() =>
    widget.roleList.indexWhere((role) => role.name == _selectedRole);

  bool _userNameIsSuperAdmin() =>
      _userNameController.text.trim().toUpperCase() == superAdminUser.toUpperCase();

}


