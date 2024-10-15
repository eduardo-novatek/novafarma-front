import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/DTOs/empty_dto.dart';
import 'package:novafarma_front/model/enums/request_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/handleError.dart';
import 'package:novafarma_front/model/globals/publics.dart';

import '../tools/fetch_data_object.dart';

Future<bool> logout(BuildContext context) async {
  await fetchDataObject<EmptyDTO>(
    uri: '$uriUserLogout/${userLogged!.userName}',
    classObject: EmptyDTO.empty(),
    requestType: RequestTypeEnum.delete
  ).then((onValue) {
    if (kDebugMode) print('Sesión cerrada con éxito por usuario ${userLogged!.userName}');
    return true;
  }).onError((error, stackTrace) {
    handleError(error: error, context: context);
  });
  return false;
}