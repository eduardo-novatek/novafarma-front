// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/role_dto1.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/custom_text_form_field.dart';

import '../../model/DTOs/role_dto.dart';


///Permite la edicion del role.
class RoleEditDialog extends StatefulWidget {
  final RoleDTO role;

  const RoleEditDialog({
    required this.role,
    super.key
  });

  @override
  State<RoleEditDialog> createState() => _RoleEditDialogState();
}

class _RoleEditDialogState extends State<RoleEditDialog> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController.value = TextEditingValue(text: widget.role.name!);
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar rol'),
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
            if (await _validatedForm(roleName: _nameController.text)) {
              if (!context.mounted) return;
              RoleDTO roleUpdated = RoleDTO(
                roleId: widget.role.roleId,
                name: _nameController.text.trim(),
                taskList: []
              );
              Navigator.of(context).pop(roleUpdated);  // Cierra el diálogo y devuelve el usuario actualizado
            }
          }
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop(null); // Cierra el diálogo devolviendo null
          },
        ),
      ],
    );
  }

  Future<bool> _validatedForm({required String roleName}) async {
    if (!_formKey.currentState!.validate()) return false;
    /*try {
      if (!_sameRoleName()) {
        /*if (await userNameExist(userName: roleName)) {
          if (context.mounted) {
            FloatingMessage.show(
                context: context,
                text: 'Usuario ya registrado: $roleName',
                messageTypeEnum: MessageTypeEnum.warning
            );
            _userNameFocusNode.requestFocus();
          }
          return false;
        }*/
      }
      /*if (_selectedRole == defaultFirstOption) {
        if (context.mounted) {
          FloatingMessage.show(
              context: context,
              text: 'Por favor, seleccione el rol',
              messageTypeEnum: MessageTypeEnum.warning
          );
        }
        return false;
      }*/
    } catch (e) {
      genericError(e, isFloatingMessage: true, context);
      return false;
    }*/
    return true;  // Validacion correcta
  }

  ///true si el nombre de usuario ingresado es el mismo que el seleccionado
  ///siempre que sea un usuario quien esté editando
  bool _sameRoleName() => widget.role.name == _nameController.text.trim();

  //int _getSelectedRole() =>
  //  widget.roleList.indexWhere((role) => role.name == _selectedRole);


}


