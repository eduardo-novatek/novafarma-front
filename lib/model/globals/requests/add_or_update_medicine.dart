
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/DTOs/medicine_dto1.dart';
import 'package:novafarma_front/model/DTOs/supplier_dto.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../enums/message_type_enum.dart';
import '../../enums/request_type_enum.dart';
import '../constants.dart' show uriMedicineAdd, uriMedicineUpdate, uriSupplierAdd, uriSupplierUpdate;
import '../tools/floating_message.dart';
import '../tools/fetch_data.dart';

///Devuelve el id del proveedor persistido o id=0 si hubo un error
Future<int?> addOrUpdateMedicine({
  required MedicineDTO1 medicine,
  required bool isAdd,
  required BuildContext context}) async {

  int id = 0; //id del medicamento persistido
  await fetchData<MedicineDTO1>(
      uri: isAdd ? uriMedicineAdd : uriMedicineUpdate,
      classObject: MedicineDTO1.empty(),
      requestType: isAdd ? RequestTypeEnum.post : RequestTypeEnum.patch,
      body: medicine

  ).then((medicineId) {
    id = medicineId.isNotEmpty ? medicineId[0] as int : medicine.medicineId!;

  }).onError((error, stackTrace) {
    String msg = '';
    if (error is ErrorObject) {
      msg = error.message ?? 'Error ${error.statusCode}';
    } else {
      msg = 'Error desconocido: ${error.toString()}';
    }
    FloatingMessage.show(
        context: context,
        text: msg,
        messageTypeEnum: MessageTypeEnum.warning,
        secondsDelay: error is ErrorObject ? 8 : 5
    );
    if (kDebugMode) print(msg);
    return Future.error(0);
  });
  return Future.value(id);
}