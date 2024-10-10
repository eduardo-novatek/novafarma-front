import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/DTOs/empty_dto.dart';
import 'package:novafarma_front/model/enums/request_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/globals/publics.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../tools/fetch_data_object.dart';

Future<void> logout(BuildContext context) async {
  await fetchDataObject<EmptyDTO>(
    uri: '$uriUserLogout/${userLogged!.userName}',
    classObject: EmptyDTO.empty(),
    requestType: RequestTypeEnum.delete
  ).then((onValue) {
    if (kDebugMode) {
      print('Sesión cerrada con éxito para el usuario ${userLogged!.userName}');
    }
  }).onError((error, stackTrace) {
    genericError(
      error is ErrorObject ? error.message! : error!,
      context.mounted ? context : context,
      isFloatingMessage: true
    );
  });
}