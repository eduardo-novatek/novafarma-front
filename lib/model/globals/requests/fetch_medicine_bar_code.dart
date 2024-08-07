import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/DTOs/presentation_dto.dart';

import '../../DTOs/medicine_dto1.dart';
import '../constants.dart' show uriMedicineFindBarCode;
import '../tools/fetch_data.dart';

Future<void> fetchMedicineBarCode({
  required String barCode,
  required MedicineDTO1 medicine,
}) async {

  await fetchData<MedicineDTO1>(
    uri: '$uriMedicineFindBarCode/$barCode',
    classObject: MedicineDTO1.empty(),
  ).then((data) {
    if (data.isNotEmpty) {
      final MedicineDTO1 fetchedMedicine = data.first as MedicineDTO1;
      medicine.medicineId = fetchedMedicine.medicineId;
      medicine.barCode = fetchedMedicine.barCode;
      medicine.name = fetchedMedicine.name;
      medicine.presentation = PresentationDTO()
          .fromJson(fetchedMedicine.presentation!.toJson());
      medicine.lastAddDate = fetchedMedicine.lastAddDate;
      medicine.lastCostPrice = fetchedMedicine.lastCostPrice;
      medicine.lastSalePrice = fetchedMedicine.lastSalePrice;
      medicine.currentStock = fetchedMedicine.currentStock;
      medicine.controlled = fetchedMedicine.controlled;
    }
  }).onError((error, stackTrace) {
    if (kDebugMode) print(error);
    //Future.error(error!);
    throw error!;
  });
}
