import 'package:flutter/material.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart' show
  dateToStr;

import '../../model/DTOs/controlled_medication_dto1.dart';

class ControlledMedicationListFromCustomerDialog extends StatelessWidget {
  final String customerName;
  final List<ControlledMedicationDTO1> medications;

  const ControlledMedicationListFromCustomerDialog({
    super.key,
    required this.medications,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.white54, //Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4, // 40% del ancho de la pantalla
          height: MediaQuery.of(context).size.height * 0.7, // 70% del alto de la pantalla
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Medicamentos Controlados',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    ControlledMedicationDTO1 medication = medications[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.medical_services, color: Colors.blue),
                          title: Text(
                            medication.medicine?.name ?? 'Sin datos',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: _subTitle(medication),
                        ),
                        const Divider(thickness: 1),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subTitle(ControlledMedicationDTO1 medication) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Última venta: ${dateToStr(medication.lastSaleDate)}'),
        Text('Frecuencia: ${medication.frequencyDays} ${_writeDays(medication.frequencyDays!)}'),
        Text('Tolerancia: ${medication.toleranceDays} ${_writeDays(medication.toleranceDays!)}'),
        _viewNextDate(
          medication.lastSaleDate,
          medication.frequencyDays! - medication.toleranceDays!,
        ),
      ],
    );
  }

  Widget _viewNextDate(DateTime? date, int days) {
    DateTime next = date != null ? date.add(Duration(days: days)) : DateTime.now();
    return Row(
      children: [
        const Text('Próximo retiro: '),
        Text(
          dateToStr(next)!,
          style: TextStyle(
            color: next.isAfter(DateTime.now()) ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _writeDays(int days) => days > 1 ? 'días' : 'día';
}


/*class ControlledMedicationListFromCustomerDialog extends StatelessWidget {
  final String customerName;
  final List<ControlledMedicationDTO1> medications;

  const ControlledMedicationListFromCustomerDialog({
    super.key,
    required this.medications,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Esquinas rectas
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3, // 20% del ancho de la pantalla
        height: MediaQuery.of(context).size.height * 0.7, // 70% del alto de la pantalla
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Medicamentos controlados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(customerName, style: const TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
              )),
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
        Text('Última venta: ${dateToStr(medication.lastSaleDate)}'),
        Text('Frecuencia: ${medication.frequencyDays} '
            '${_writeDays(medication.frequencyDays!)}'),
        Text('Tolerancia: ${medication.toleranceDays} '
            '${_writeDays(medication.toleranceDays!)}'),
        _viewNextDate(
          medication.lastSaleDate,
          medication.frequencyDays! - medication.toleranceDays!,
        )
      ],
    );
  }

  Widget _viewNextDate(DateTime? date, int days) {
    DateTime next = date != null ? date.add(Duration(days: days)) : DateTime.now();
    return Row(
      children: [
        const Text('Próximo retiro: '),
        Text('${dateToStr(next)}',
          style: TextStyle(color: next.isAfter(DateTime.now())
            ? Colors.red
            : Colors.green,
          )
        ),
      ],
    );
  }

  String _writeDays(int days) => days > 1 ? 'días' : 'día';

}*/
