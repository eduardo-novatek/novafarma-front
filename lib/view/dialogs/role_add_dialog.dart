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

class RoleAddDialog extends StatefulWidget {
  const RoleAddDialog({super.key});
  // const UserAddDialog(this.roleList, {super.key}); //, required this.scaffoldKey});

  //final List<RoleDTO> roleList;

  @override
  State<RoleAddDialog> createState() => _RoleAddDialogState();
}

class _RoleAddDialogState extends State<RoleAddDialog> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  //String selectedRole = defaultFirstOption;
  ThemeData themeData = ThemeData();

  @override
  void initState() {
    super.initState();
    /*if (!widget.roleList[0].isFirst!) {
      widget.roleList.insert(
          0,
          RoleDTO(
              isFirst: true, roleId: null, name: defaultFirstOption)
      );
    }*/
  }

  @override
  void dispose() {
    super.dispose();
    //widget.roleList[0].isFirst == true ? widget.roleList.removeAt(0) : null;
    _nameController.dispose();
    _nameFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar rol'),
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
                    maxValueForValidation: 19,
                    textForValidation: 'El nombre es requerido',
                  ),
                  /*Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text("Rol:"),
                      ),
                      CustomDropdown<RoleDTO>(
                        themeData: themeData,
                        optionList: widget.roleList,
                        selectedOption: widget.roleList[0],
                        isSelected: true,
                        callback: (role) {
                          selectedRole = role!.name;
                        },
                      ),
                    ],
                  )*/
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
            if (await _validatedForm(rolName: _userNameController.text)) {
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

  Future<bool> _validatedForm({required String rolName}) async {

    //Valida el formulario
    if (!_formKey.currentState!.validate()) return false;

    try {
      if (await userNameExist(userName: rolName)) {
        if (context.mounted) {
          FloatingMessage.show(
              context: context,
              text: 'Usuario ya registrado: $rolName',
              messageTypeEnum: MessageTypeEnum.warning
          );
          _userNameFocusNode.requestFocus();
        }
        return false;
      }

      if (selectedRole == defaultFirstOption) {
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
      FloatingMessage.show(
          context: context,
          text: "Error de conexión",
          messageTypeEnum: MessageTypeEnum.error
      );
      return false;
    }
    return true;  // Validacion correcta
  }


}


