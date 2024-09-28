// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/role_dto1.dart';
import 'package:novafarma_front/model/DTOs/role_dto2.dart';
import 'package:novafarma_front/model/DTOs/task_dto.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/custom_text_form_field.dart';

import '../../model/DTOs/role_dto.dart';
import '../../model/globals/task_selection.dart';


class RoleAddDialog extends StatefulWidget {
  final List<TaskDTO> taskList;

  const RoleAddDialog({super.key, required this.taskList});

  @override
  State<RoleAddDialog> createState() => _RoleAddDialogState();
}

class _RoleAddDialogState extends State<RoleAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  List<TaskDTO> _selectedTasks = [];

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
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
              constraints: const BoxConstraints(minWidth: 300),
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
                  const SizedBox(height: 20),
                  TaskSelection(
                    taskList: widget.taskList,
                    onTaskSelectionChanged: (selectedTasks) {
                      _selectedTasks = selectedTasks;
                    },
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
            if (_invalidRoleName()) {
              _nameController.value = TextEditingValue.empty;
            }
            if (!_formKey.currentState!.validate()) return;
            RoleDTO newRole = RoleDTO(
              roleId: null,
              name: _nameController.text,
              taskList: _selectedTasks,
            );
            Navigator.of(context).pop(newRole);
          },
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  ///True si el nombre del rol es inválido (si contiene SUP y AD). Indicios que contiene super admin o similiar
  bool _invalidRoleName() =>
    _nameController.text.toUpperCase().contains('SUP') &&
    _nameController.text.toUpperCase().contains('AD');

}


