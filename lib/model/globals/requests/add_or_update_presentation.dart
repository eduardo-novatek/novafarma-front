
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/DTOs/presentation_dto.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../DTOs/presentation_dto_1.dart';
import '../../enums/message_type_enum.dart';
import '../../enums/request_type_enum.dart';
import '../constants.dart' show uriPresentationAdd, uriPresentationUpdate;
import '../tools/floating_message.dart';
import '../tools/fetch_data_object.dart';

///Devuelve el id de la presentacion persistida o id=0 si hubo un error
Future<int> addOrUpdatePresentation({
  required PresentationDTO1 presentation,
  required bool isAdd,
  required BuildContext context}) async {

  int id = 0; //id del objeto persistido

  await fetchDataObject<PresentationDTO1>(
      uri: isAdd ? uriPresentationAdd : uriPresentationUpdate,
      classObject: PresentationDTO1.empty(),
      requestType: isAdd ? RequestTypeEnum.post : RequestTypeEnum.patch,
      body: presentation

  ).then((presentationId) {
    id = presentationId.isNotEmpty
      ? presentationId[0] as int
      : presentation.presentationId!;

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