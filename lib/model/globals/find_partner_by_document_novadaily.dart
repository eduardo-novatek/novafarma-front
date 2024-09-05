

import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:novafarma_front/model/DTOs/partner_nova_daily_dto.dart';
import 'package:novafarma_front/model/globals/requests/fetch_partner_nova_daily_list.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

///Dada una cedula, devuelve el socio encontrado (PartnerNovaDailyDTO) o null si no lo encuentra o lanzó excepcion.
Future<PartnerNovaDailyDTO?> findPartnerByDocumentNovaDaily({
  required String document,
  required BuildContext context,
}) async {
  List<PartnerNovaDailyDTO> partnerNovaDailyList = [];
  try {
    await fetchPartnerNovaDailyList(
      partnerNovaDailyList: partnerNovaDailyList,
      searchByDocument: true,
      value: document,
    );
    if (partnerNovaDailyList.isNotEmpty) {
      return partnerNovaDailyList[0];
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
  }
  return null;
}