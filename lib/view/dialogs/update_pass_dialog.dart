// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/empty_dto.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/enums/request_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/handleError.dart';
import 'package:novafarma_front/model/globals/tools/custom_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/fetch_data_object.dart';

import '../../model/globals/tools/build_circular_progress.dart';
import '../../model/globals/tools/floating_message.dart';

///Permite el cambio de las credenciales del usuario (pass)
class UpdatePassDialog extends StatefulWidget {
  final int userId;

  const UpdatePassDialog({super.key, required this.userId});

  @override
  State<UpdatePassDialog> createState() => _UpdatePassDialogState();
}

class _UpdatePassDialogState extends State<UpdatePassDialog> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _newPassRepeatController = TextEditingController();

  final FocusNode _newPassFocusNode = FocusNode();
  final FocusNode _newPassRepeatFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _newPassController.dispose();
    _newPassRepeatController.dispose();
    _newPassFocusNode.dispose();
    _newPassRepeatFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _isLoading,
          child: _buildAlertDialog(context),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
                child: buildCircularProgress(size: 20.0)
            ),
          ),
      ]
    );
  }

  AlertDialog _buildAlertDialog(BuildContext context) {
    return AlertDialog(
        title: const Text('Actualizar credenciales'),
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
                      controller: _newPassController,
                      focusNode: _newPassFocusNode,
                      label: 'Nueva contraseña',
                      initialFocus: true,
                      dataType: DataTypeEnum.password,
                      maxValueForValidation: 10,
                      onEditingComplete: () =>
                          FocusScope.of(context).requestFocus(_newPassRepeatFocusNode),
                    ),
                    const SizedBox(height: 10.0,),

                    CustomTextFormField(
                        controller: _newPassRepeatController,
                        focusNode: _newPassRepeatFocusNode,
                        label: 'Repetir contraseña',
                        dataType: DataTypeEnum.password,
                        maxValueForValidation: 10,
                        onEditingComplete: () => _submit()
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
              onPressed: () => _submit()
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

  Future<void> _submit() async {
    if (! _formKey.currentState!.validate()) return;
    if (_newPassController.text == _newPassRepeatController.text) {
      setState(() {
        _isLoading = true;
      });

      await fetchDataObject<EmptyDTO>(
        uri: '$uriUserUpdateCredentials/'
            '${widget.userId}/'
            '${_newPassController.text}',
        classObject: EmptyDTO.empty(),
        requestType: RequestTypeEnum.put
      ).then((value) {
        FloatingMessage.show(
          context: context,
          text: 'Credenciales actualizadas con éxito',
          messageTypeEnum: MessageTypeEnum.info
        );
        Navigator.of(context).pop();
      }).onError((error, stackTrace) {
        if (mounted) handleError(error: error, context: context);
      });

      setState(() {
        _isLoading = false;
      });

    } else {
      FloatingMessage.show(
          context: context,
          text: 'Las contraseñas no coinciden',
          messageTypeEnum: MessageTypeEnum.warning
      );
    }
  }

}


