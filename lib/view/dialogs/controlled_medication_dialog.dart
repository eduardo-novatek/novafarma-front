import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/controlled_medication_dto.dart';

import '../../model/enums/data_type_enum.dart';
import '../../model/globals/tools/create_text_form_field.dart';

class ControlledMedicationDialog extends StatefulWidget {
  final ControlledMedicationDTO controlledMedication;  //Se actualiza con los datos seleccionados

  const ControlledMedicationDialog({
    super.key,
    required this.controlledMedication,
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
            width: constraints.maxWidth * 0.15, // 15% del ancho disponible
            height: constraints.maxHeight * 0.2, // 20% del alto disponible
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
            child: Column(
              children: [
                Text(widget.modifyVoucherItem == null
                    ? 'Agregar medicamento controlado'
                    : 'Modificar medicamento controlado',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.modifyVoucherItem == null
                              ? CreateTextFormField(
                            controller: _frequencyDaysController,
                            focusNode: _frequencyDaysFocusNode,
                            label: 'Frecuencia de compra',
                            dataType: DataTypeEnum.number,
                            minValueForValidation: 0,
                            maxValueForValidation: 365,
                            textForValidation: 'Ingrese un valor entre 0 y 365',
                            initialFocus: true,
                          )
                              : Text('Çódigo: ${widget.modifyVoucherItem?.barCode}'),

                          const SizedBox(height: 20),
                          _buildTable(),
                          const SizedBox(height: 5),

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
                        onPressed: () {
                            if (!_formKey.currentState!.validate()) return;
                            if (_validate()) {
                              Navigator.of(context).pop();
                            } else {

                            }
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        child: const Text("Cancelar"),
                        onPressed: () {
                          Navigator.of(context).pop();
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

}
