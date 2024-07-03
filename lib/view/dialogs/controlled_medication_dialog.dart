// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/controlled_medication_dto1.dart';

import '../../model/enums/data_type_enum.dart';
import '../../model/globals/tools/message.dart';
import '../../model/globals/tools/create_text_form_field.dart';

class ControlledMedicationDialog extends StatefulWidget {
  //Se actualiza con los datos ingresados de Frecuencia y Tolernacia.
  //Si cancela, controlledMedication se reasigna a null.
  ControlledMedicationDTO1? controlledMedication;
  final bool isAdd; //alta=true, si es un update=false

  ControlledMedicationDialog({
    super.key,
    this.controlledMedication,
    required this.isAdd,
  });

  @override
  State<ControlledMedicationDialog> createState() => _ControlledMedicationDialogState();
}

class _ControlledMedicationDialogState extends State<ControlledMedicationDialog> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _frequencyDaysController = TextEditingController();
  final TextEditingController _toleranceDaysController = TextEditingController();

  final FocusNode _frequencyDaysFocusNode = FocusNode();
  final FocusNode _toleranceDaysFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _addListeners();
    if (widget.isAdd) {
      _frequencyDaysController.value = TextEditingValue(text: '0');
      _toleranceDaysController.value = TextEditingValue(text: '0');
      // Es modificacion
    } else {
      _frequencyDaysController.value = TextEditingValue(
        text: widget.controlledMedication!.frequencyDays.toString()
      );
      _toleranceDaysController.value = TextEditingValue(
          text: widget.controlledMedication!.toleranceDays.toString()
      );
    }

  }

  @override
  void dispose() {
    super.dispose();
    _frequencyDaysController.dispose();
    _toleranceDaysController.dispose();

    _frequencyDaysFocusNode.dispose();
    _toleranceDaysFocusNode.dispose();
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
            width: constraints.maxWidth * 0.30, // % del ancho disponible
            height: constraints.maxHeight * 0.49,
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.isAdd
                    ? 'Vincular medicamento controlado'
                    : 'Actualizar vínculo de medicamento controlado',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text('Paciente: ${widget.controlledMedication!.customerName}'),
                Text('Medicamento: ${widget.controlledMedication!.medicineName}'),
                widget.controlledMedication!.lastSaleDate != null
                  ? Text('Ultima venta: ${widget.controlledMedication!.lastSaleDate}')
                  : const SizedBox.shrink(),
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CreateTextFormField(
                            controller: _frequencyDaysController,
                            focusNode: _frequencyDaysFocusNode,
                            label: 'Frecuencia de compra',
                            dataType: DataTypeEnum.number,
                            minValueForValidation: 0,
                            maxValueForValidation: 365,
                            textForValidation: 'Ingrese un valor entre 0 y 365',
                            initialFocus: true,
                          ),
                          const SizedBox(height: 20),
                          CreateTextFormField(
                            controller: _toleranceDaysController,
                            focusNode: _toleranceDaysFocusNode,
                            label: 'Tolerancia',
                            dataType: DataTypeEnum.number,
                            minValueForValidation: 0,
                            maxValueForValidation: 365,
                            textForValidation: 'Ingrese un valor entre 0 y 365',
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 27.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: const Text("Aceptar"),
                        onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            if (int.parse(_frequencyDaysController.text) <
                                int.parse(_toleranceDaysController.text)) {
                              await message(
                                message: 'La frecuencia de compra debe ser mayor o igual a los días de tolerancia',
                                context: context,
                              );
                              _frequencyDaysFocusNode.requestFocus();
                              return;
                            }
                            _updateControlledMedication();
                            //Devuelve true, con lo cual el objeto controlledMedication está actualizado
                            Navigator.of(context).pop(true);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        child: const Text("Cancelar"),
                        onPressed: () {
                          widget.controlledMedication = null;
                          //Devuelve false, con lo cual el objeto controlledMedication está inicializado
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateControlledMedication() {
    widget.controlledMedication!.frequencyDays = int.parse(_frequencyDaysController.text);
    widget.controlledMedication!.toleranceDays = int.parse(_toleranceDaysController.text);
  }

  _addListeners() {
    _frequenceDaysListener();
    _toleranceDaysListener();
  }

  void _toleranceDaysListener() {
    _toleranceDaysFocusNode.addListener(() {
      if (_toleranceDaysFocusNode.hasFocus) {
        _toleranceDaysController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _toleranceDaysController.text.length
        );
      }
    });
  }

  void _frequenceDaysListener() {
    _frequencyDaysFocusNode.addListener(() {
      if (_frequencyDaysFocusNode.hasFocus) {
        _frequencyDaysController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _frequencyDaysController.text.length
        );
      }
    });
  }

}
