
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/DTOs/unit_dto.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../enums/message_type_enum.dart';
import '../../enums/request_type_enum.dart';
import '../constants.dart' show uriUnitAdd, uriUnitUpdate;
import '../generic_error.dart';
import '../tools/floating_message.dart';
import '../tools/fetch_data_object.dart';

///Devuelve el id de la unidad de medida persistida o id=0 si hubo un error
Future<int?> addOrUpdateUnit({
  required UnitDTO unit,
  required bool isAdd,
  required BuildContext context}) async {

  int id = 0; //id de la unidad persistida
  await fetchDataObject<UnitDTO>(
      uri: isAdd ? uriUnitAdd : uriUnitUpdate,
      classObject: UnitDTO.empty(),
      requestType: isAdd ? RequestTypeEnum.post : RequestTypeEnum.patch,
      body: unit

  ).then((unitId) {
    id = unitId.isNotEmpty ? unitId[0] as int : unit.unitId!;

  }).onError((error, stackTrace) {
    String msg = '';
    if (error is ErrorObject) {
      msg = error.message ?? 'Error ${error.statusCode}';
      FloatingMessage.show(
          context: context,
          text: msg,
          messageTypeEnum: MessageTypeEnum.warning
      );
    } else {
      msg = error!.toString();
      genericError(error, context, isFloatingMessage: true);
    }
    if (kDebugMode) print(msg);
    return Future.error(0);
  });
  return Future.value(id);
}