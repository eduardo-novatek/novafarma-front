// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/controlled_medication_dto.dart';

import '../../model/enums/data_type_enum.dart';
import '../../model/globals/message.dart';
import '../../model/globals/tools/create_text_form_field.dart';

class ControlledMedicationDialog extends StatefulWidget {
  //Se actualiza con los datos ingresados de Frecuencia y Tolernacia.
  //Si cancela, controlledMedication se reasigna a null.
  ControlledMedicationDTO? controlledMedication;
  //final CustomerDTO customer;

  ControlledMedicationDialog({
    super.key,
    this.controlledMedication,
    //required this.customer,
  });

  @override
  State<ControlledMedicationDialog> createState() => _ControlledMedicationDialogState();
}

class _ControlledMedicationDialogState extends State<ControlledMedicationDialog> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _frequencyDaysController = TextEditingController();
  final TextEditingController _toleranceDaysController = TextEditingController();
  final TextEditingController _lastSaleDateController = TextEditingController();

  final FocusNode _frequencyDaysFocusNode = FocusNode();
  final FocusNode _toleranceDaysFocusNode = FocusNode();
  final FocusNode _lastSaleDateFocusNode = FocusNode();

  late final bool isAdd;

  @override
  void initState() {
    super.initState();
    isAdd = (widget.controlledMedication?.customerId == null
        || widget.controlledMedication?.customerId! == 0);

    if (isAdd) {
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
    _lastSaleDateController.dispose();

    _frequencyDaysFocusNode.dispose();
    _toleranceDaysFocusNode.dispose();
    _lastSaleDateFocusNode.dispose();
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
            width: constraints.maxWidth * 0.30, // 15% del ancho disponible
            height: constraints.maxHeight * 0.50, // 20% del alto disponible
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isAdd
                    ? 'Agregar medicamento controlado'
                    : 'Actualizar medicamento controlado',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                widget.controlledMedication!.lastSaleDate == null
                  ? const Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '* Primera venta *',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  )
                  : const SizedBox.shrink(),
                //Text('Paciente: ${widget.customer.name} ${widget.customer.lastname}'),
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
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
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
                      TextButton(
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

}
