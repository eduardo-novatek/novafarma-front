import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/medicine_dto3.dart';

///Dado el nombre de un medicamento, carga una lista de medicamentos que
///coincida parcialmente en su nombre, y cada uno con sus diferentes presentaciones.
///Devuelve el medicamento seleccionado o  null si canceló.
Future<MedicineDTO3?> medicineAndPresentationListDialog(
    {required String medicineName, required BuildContext context,}) async {

  MedicineDTO3? medicineSelected;

  await showDialog(
      context: context,
      barrierDismissible: false, //modal
      builder: (BuildContext context) {
        return PopScope( //Evita salida con flecha atras del navegador
          canPop: false,
          child: _MedicineDialog(
            medicineName: medicineName,
            onSelect: (medicine) => medicineSelected = medicine
          ),
        );
      }
  ).then((value) async {
    medicineSelected = value as MedicineDTO3?;
  });
  return Future.value(medicineSelected);
}

class _MedicineDialog extends StatelessWidget {
  final List<MedicineDTO3> medicines = [];
  final Function(MedicineDTO3?) onSelect;
  final String medicineName;

  _MedicineDialog({
    required this.medicineName,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Esquinas rectas
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8.0,),
          Expanded(
            child: FutureBuilder<List<MedicineDTO3>>(
              future: _loadMedicines(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  List<MedicineDTO3> data = snapshot.data!;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          '${data[index].name!} '
                          '${data[index].presentation!.name} '
                          '${data[index].presentation!.quantity} '
                          '${data[index].presentation!.unitName}',
                        ),
                        onTap: () => onSelect(
                          MedicineDTO3(
                            medicineId: data[index].medicineId,
                            name: data[index].name,
                            presentation: data[index].presentation,
                            controlled: data[index].controlled
                          )
                        ),
                      );
                    },
                  );
                } else {
                  return const Text('Sin datos');
                }
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton(
              onPressed: () {
                onSelect(null);
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ),
        ]
      ),
    );
    /*return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Esquinas rectas
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3, // 30% del ancho de la pantalla
        height: MediaQuery.of(context).size.height * 0.5, // 50% del alto de la pantalla
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8.0,),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(), // Permitir desplazamiento siempre
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final medicine = medicines[index];
                  return ListTile(
                    title: Text(
                      '${medicine.name} '
                      '${medicine.presentation!.name} '
                      '${medicine.presentation!.quantity} '
                       '${medicine.presentation!.unitName}'
                    ),
                    onTap: () {
                      onSelect(MedicineDTO3(
                        medicineId: medicine.medicineId,
                        name: medicine.name,
                        presentation: medicine.presentation,
                        controlled: medicine.controlled
                      )); //devuelve el índice seleccionado
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  onSelect(null);
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );*/
  }

  ///Carga la lista de medicamentos segun el nombre ingresado
  Future<List<MedicineDTO3>> _loadMedicines() async {
    List<MedicineDTO3> medicines = [];

    return medicines;
  }

}
