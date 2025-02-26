
import 'package:flutter/cupertino.dart';
import 'package:novafarma_front/model/DTOs/medicine_dto1.dart';
import 'package:novafarma_front/model/globals/handleError.dart';

import '../../enums/request_type_enum.dart';
import '../constants.dart' show uriMedicineAdd, uriMedicineUpdate;
import '../tools/fetch_data_object.dart';

///Devuelve el id del medicamento persistido o id=0 si hubo un error
Future<int?> addOrUpdateMedicine({
  required MedicineDTO1 medicine,
  required bool isAdd,
  required BuildContext context}) async {

  int id = 0; //id del medicamento persistido
  await fetchDataObject<MedicineDTO1>(
      uri: isAdd ? uriMedicineAdd : uriMedicineUpdate,
      classObject: MedicineDTO1.empty(),
      requestType: isAdd ? RequestTypeEnum.post : RequestTypeEnum.patch,
      body: medicine

  ).then((medicineId) {
    id = medicineId.isNotEmpty ? medicineId[0] as int : medicine.medicineId!;

  }).onError((error, stackTrace) {
    handleError(error: error, context: context);
    return Future.error(0);
  });
  return Future.value(id);
}