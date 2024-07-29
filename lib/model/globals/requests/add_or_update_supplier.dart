
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/DTOs/supplier_dto.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../enums/message_type_enum.dart';
import '../../enums/request_type_enum.dart';
import '../constants.dart' show uriSupplierAdd, uriSupplierUpdate;
import '../tools/floating_message.dart';
import '../tools/fetch_data.dart';

///Devuelve el id del cliente persistido o id=0 si hubo un error
Future<int?> addOrUpdateSupplier({
  required SupplierDTO supplier,
  required bool isAdd,
  required BuildContext context}) async {

  int id = 0; //id del proveedor persistido
  await fetchData<SupplierDTO>(
      uri: isAdd ? uriSupplierAdd : uriSupplierUpdate,
      classObject: SupplierDTO.empty(),
      requestType: isAdd ? RequestTypeEnum.post : RequestTypeEnum.patch,
      body: supplier

  ).then((supplierId) {
    id = supplierId.isNotEmpty ? supplierId[0] as int : supplier.supplierId!;

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
        messageTypeEnum: MessageTypeEnum.warning
    );
    if (kDebugMode) print(msg);
    return Future.error(0);
  });
  return Future.value(id);
}