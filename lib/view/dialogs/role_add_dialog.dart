// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/role_dto1.dart';
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
            if (!_formKey.currentState!.validate() || !context.mounted) return;
            RoleDTO1 newRole = RoleDTO1(
              roleId: null,
              name: _nameController.text,
            );
            // Cierra el diálogo y devuelve el nuevo usuario
            Navigator.of(context).pop(newRole);
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

}


