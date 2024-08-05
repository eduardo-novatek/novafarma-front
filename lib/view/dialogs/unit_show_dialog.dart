
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../model/DTOs/unit_dto.dart';
import '../../model/enums/data_type_enum.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/requests/add_or_update_unit.dart';
import '../../model/globals/tools/build_circular_progress.dart';
import '../../model/globals/tools/create_text_form_field.dart';
import '../../model/globals/tools/floating_message.dart';
import '../../model/globals/tools/open_dialog.dart';

///Permite el alta de una nueva unidad de medida. Devuelve el nombre de la
///nueva unidad persistida o null si ocurrió un error
Future<String> unitShowDialog({
  required BuildContext context,
  required bool isAdd
}) async {

  String? unit;
  await showDialog(
      context: context,
      barrierDismissible: false, //modal
      builder: (BuildContext context) {
        return PopScope( //Evita salida con flecha atras del navegador
            canPop: false,
            child: _UnitDialog(context: context, isAdd: isAdd),
        );
      }
  ).then((value) async {
    unit = value;
  });
  return Future.value(unit);
}

class _UnitDialog extends StatefulWidget {
  final BuildContext context;
  final bool isAdd;

  const _UnitDialog({required this.context, required this.isAdd});

  @override
  State<_UnitDialog> createState() => _UnitDialogState();
}

class _UnitDialogState extends State<_UnitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _unitNameController = TextEditingController();
  final _unitNameFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
    _unitNameController.dispose();
    _unitNameFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Esquinas rectas
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth * 0.2, // % del ancho disponible
            height: constraints.maxHeight * (widget.isAdd ? 0.26 : 0.4),
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
            child: Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Stack(
                    children: [
                      AbsorbPointer(
                        absorbing: _isLoading,
                        child:
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          // Ajusta el tamaño vertical al contenido
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Nueva unidad de medida',
                              style: TextStyle(fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            CreateTextFormField(
                              label: 'Unidad de medida',
                              controller: _unitNameController,
                              focusNode: _unitNameFocusNode,
                              dataType: DataTypeEnum.text,
                              maxValueForValidation: 4,
                              viewCharactersCount: false,
                              textForValidation: 'Requerido',
                              acceptEmpty: false,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 27.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      child: const Text("Aceptar"),
                                      onPressed: () async {
                                        if (!_formKey.currentState!.validate()) return;
                                        if (await _confirm() == 1) {
                                          await _submitForm().then((unit) {
                                            if (mounted) {
                                              Navigator.of(context).pop(unit);
                                            }
                                          }).onError((error, stackTrace) {
                                            if (mounted) {
                                              Navigator.of(context).pop(null);
                                            }
                                          });
                                        } else {
                                          Navigator.of(context).pop(null);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      child: const Text("Cancelar"),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isLoading)
                        Positioned.fill(
                            child: Container(
                                child: buildCircularProgress(size: 30.0)
                            )
                        ),
                    ]
                  )
                ),
              ),
            ),
          );
        }
      )
    );

  }

  Future<int> _confirm() async {
    return await OpenDialog(
        title: 'Confirmar',
        content: widget.isAdd
          ? '¿Agregar la unidad de medida?'
          : '¿Actualizar la unidad de medida?',
        textButton1: 'Si',
        textButton2: 'No',
        context: widget.context
    ).view();
  }

  Future<String> _submitForm() async {
    String? unit;
    _changeStateLoading(true);
    await addOrUpdateUnit(
        unit: UnitDTO(name: _unitNameController.text.trim()),
        isAdd: widget.isAdd,
        context: widget.context

    ).then((unitId) {
      _changeStateLoading(false);
      String msg = 'Unidad de medida ${widget.isAdd ? 'agregada' : 'actualizada'} con éxito';
      FloatingMessage.show(
          text: msg,
          messageTypeEnum: MessageTypeEnum.info,
          context: widget.context
      );
      if (kDebugMode) print('$msg (id: $unitId)');
      unit =  _unitNameController.text.trim().toUpperCase();

    }).onError((error, stackTrace) {
      _changeStateLoading(false);
    });
    return Future.value(unit);
  }

  void _changeStateLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }
}
