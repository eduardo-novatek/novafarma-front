
import 'package:flutter/cupertino.dart';
import 'package:novafarma_front/model/DTOs/unit_dto.dart';
import 'package:novafarma_front/model/globals/handleError.dart';

import '../../enums/request_type_enum.dart';
import '../constants.dart' show uriUnitAdd, uriUnitUpdate;
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
    handleError(error: error, context: context);
    return Future.error(0);
  });
  return Future.value(id);
}