import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/DTOs/presentation_dto.dart';

import '../../DTOs/medicine_dto1.dart';
import '../../objects/error_object.dart';
import '../constants.dart' show uriMedicineFindBarCode;
import '../tools/fetch_data_object.dart';
import '../tools/floating_message.dart';

Future<void> fetchMedicineBarCode({
  required String barCode,
  required MedicineDTO1 medicine,
}) async {

  await fetchDataObject<MedicineDTO1>(
    uri: '$uriMedicineFindBarCode/$barCode',
    classObject: MedicineDTO1.empty(),
  ).then((data) {
    if (data.isNotEmpty) {
      final MedicineDTO1 fetchedMedicine = data.first as MedicineDTO1;
      if(fetchedMedicine.deleted!) {
        throw ErrorObject(
            statusCode: HttpStatus.conflict,
            message: 'El medicamento está eliminado'
        );
      }
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
      medicine.deleted = fetchedMedicine.deleted;
    }
  }).onError((error, stackTrace) {
    //Future.error(error!);
    throw error!;
  });
}
