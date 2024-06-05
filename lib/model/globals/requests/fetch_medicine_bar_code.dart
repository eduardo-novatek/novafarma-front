import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/DTOs/presentation_dto.dart';

import '../../DTOs/medicine_dto.dart';
import '../constants.dart' show uriMedicineFindBarCode;
import 'fetch_data_object.dart';

Future<void> fetchMedicineBarCode({
  required String barCode,
  required MedicineDTO medicine,
}) async {

  await fetchDataObject<MedicineDTO>(
    uri: '$uriMedicineFindBarCode/$barCode',
    classObject: MedicineDTO.empty(),
  ).then((data) {
    if (data.isNotEmpty) {
      final MedicineDTO fetchedMedicine = data.first as MedicineDTO;
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
    throw Exception(error);
  });
}
