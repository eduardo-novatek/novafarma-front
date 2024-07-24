import 'package:flutter/material.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart' show
  dateToStr;

import '../../model/DTOs/controlled_medication_dto1.dart';

class ControlledMedicationListFromCustomerDialog extends StatelessWidget {
  final List<ControlledMedicationDTO1> medications;

  const ControlledMedicationListFromCustomerDialog({
    super.key,
    required this.medications
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Esquinas rectas
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2, // 20% del ancho de la pantalla
        height: MediaQuery.of(context).size.height * 0.5, // 50% del alto de la pantalla
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  ControlledMedicationDTO1 medication = medications[index];
                  return ListTile(
                    title: Text(medication.medicine?.name ?? 'Sin datos'),
                    subtitle: _subTitle(medication),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _subTitle(ControlledMedicationDTO1 medication) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ultima venta: ${dateToStr(medication.lastSaleDate)}'),
        Text('Frecuencia: ${medication.frequencyDays} días'),
        Text('Tolerancia: ${medication.toleranceDays} días'),
      ],
    );
  }
}
