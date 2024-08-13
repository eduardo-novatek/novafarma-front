
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
Future<String?> unitShowDialog(
    {UnitDTO? unitDTO, required BuildContext context,}
) async {

  String? unit;
  await showDialog(
      context: context,
      barrierDismissible: false, //modal
      builder: (BuildContext context) {
        return PopScope( //Evita salida con flecha atras del navegador
            canPop: false,
            child: _UnitDialog(context: context, unit: unitDTO),
        );
      }
  ).then((value) async {
    unit = value as String?;
  });
  return Future.value(unit);
}

class _UnitDialog extends StatefulWidget {
  final BuildContext context;
  final UnitDTO? unit;

  const _UnitDialog({required this.context, required this.unit});

  @override
  State<_UnitDialog> createState() => _UnitDialogState();
}

class _UnitDialogState extends State<_UnitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _unitNameController = TextEditingController();
  final _unitNameFocusNode = FocusNode();
  bool _isLoading = false;
  late bool _isAdd;

  @override
  void initState(){
    super.initState();
    _isAdd = (widget.unit == null);
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
            height: constraints.maxHeight * (_isAdd ? 0.24 : 0.3),
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40),
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
                          Text(_isAdd
                            ? 'Nueva unidad de medida'
                            : 'Modificar unidad de medida',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          if (! _isAdd)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 11.0),
                              child: Text('Unidad: ${widget.unit?.name}'),
                            ),
                          Container(
                            padding: const EdgeInsets.only(right: 170),
                            child: CreateTextFormField(
                              label: _isAdd ? 'Unidad' : 'Nueva',
                              controller: _unitNameController,
                              focusNode: _unitNameFocusNode,
                              dataType: DataTypeEnum.text,
                              maxValueForValidation: 4,
                              viewCharactersCount: false,
                              initialFocus: true,
                              textForValidation: 'Requerido',
                              acceptEmpty: false,
                            ),
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
                                      Navigator.of(context).pop(null);
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
          );
        }
      )
    );

  }

  Future<int> _confirm() async {
    return await OpenDialog(
        title: 'Confirmar',
        content: _isAdd
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
        unit: UnitDTO(
            unitId: _isAdd ? null: widget.unit?.unitId,
            name: _unitNameController.text.trim()),
        isAdd: _isAdd,
        context: widget.context

    ).then((unitId) {
      _changeStateLoading(false);
      String msg = 'Unidad de medida ${_isAdd ? 'agregada' : 'actualizada'} con éxito';
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
