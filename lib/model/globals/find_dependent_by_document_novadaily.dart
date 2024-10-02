import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:novafarma_front/model/DTOs/dependent_nova_daily_dto.dart';
import 'package:novafarma_front/model/globals/requests/fetch_dependent_nova_daily_list.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

///Dada una cedula, devuelve el Dependiente encontrado (DependentNovaDailyDTO) o null
///si no lo encuentra o lanzó excepcion.
Future<DependentNovaDailyDTO?> findDependentByDocumentNovaDaily({
  required String document,
  required BuildContext context,
}) async {
  List<DependentNovaDailyDTO> dependentNovaDailyList = [];
  try {
    await fetchDependentNovaDailyList(
      dependentNovaDailyList: dependentNovaDailyList,
      searchByDocument: true,
      value: document,
    );
    if (dependentNovaDailyList.isNotEmpty) {
      return dependentNovaDailyList[0];
    } else {
      return null;
    }

  } catch (error) {
    if (error is ErrorObject) {
      if (error.statusCode != HttpStatus.notFound) {
        await OpenDialog(
            context: context,
            title: 'Error',
            content: error.message != null
                ? error.message!
                : 'Error ${error.statusCode}'
        ).view();
      }
    } else {
      if (error.toString().contains('XMLHttpRequest error')) {
        await OpenDialog(
          context: context,
          title: 'Error de conexión',
          content: 'No es posible conectar con el servidor',
        ).view();
      } else {
        if (error.toString().contains('TimeoutException')) {
          await OpenDialog(
            context: context,
            title: 'Error de conexión',
            content: 'No es posible conectar con el servidor.\nTiempo expirado.',
          ).view();
        } else {
          await OpenDialog(
            context: context,
            title: 'Error desconocido',
            content: error.toString(),
          ).view();
        }
      }
    }
    return Future.error(error);
  }
}