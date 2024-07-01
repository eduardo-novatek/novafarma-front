import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/globals/tools/capitalize_first_letter.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../DTOs/controlled_medication_dto.dart';
import '../../enums/message_type_enum.dart';
import '../../enums/request_type_enum.dart';
import '../constants.dart' show uriControlledMedicationAdd;
import '../tools/floating_message.dart';
import 'fetch_data_object.dart';

Future<void> addControlledMedication({
  required ControlledMedicationDTO controlledMedication,
  required BuildContext context}) async {

  await fetchDataObject(
      uri: uriControlledMedicationAdd,
      classObject: controlledMedication,
      requestType: RequestTypeEnum.post,
      body: controlledMedication

  ).then((newControlledMedicationId) {
    if (kDebugMode) {
      print('Medicamento controlado agregado con éxito (id: '
          '$newControlledMedicationId)');
    }

  }).onError((error, stackTrace) {
    String msg = '';
    if (error is ErrorObject) {
      if (error.statusCode == HttpStatus.notFound) {
        if (error.message!.contains('EL CLIENTE CON ID')) {
          msg = 'El cliente no existe';
        } else if (error.message!.contains('EL MEDICAMENTO CON ID')) {
          msg = 'El medicamento no existe';
        }
      } else if (error.statusCode == HttpStatus.found) {
        msg = 'El cliente ya posee un registro del medicamento controlado';
      } else if (error.statusCode == HttpStatus.conflict) {
        msg = 'El medicamento no es controlado';
      } else if (error.statusCode == HttpStatus.partialContent) {
        msg = capitalizeFirstLetter(error.message!); //Toma el message literal del server
      } else { //InternalServerError
        msg = 'InternalServerError: $error';
      }

    } else {
      msg = 'Error desconocido: ${error.toString()}';
    }
    FloatingMessage.show(
        context: context,
        text: msg,
        messageTypeEnum: MessageTypeEnum.warning
    );
    if (kDebugMode) print(msg);
  });
}