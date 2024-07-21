import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/DTOs/partner_nova_daily_dto.dart';
import 'package:novafarma_front/model/globals/requests/fetch_data_nova_daily.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../constants.dart' show uriNovaDailyFindPartnerDocument,
  uriNovaDailyFindPartnerLastname;

/// searchByDocument: true=buscar por documento. false=buscar por apellido
Future<void> fetchPartnerNovaDailyList({
  required List<PartnerNovaDailyDTO> partnerNovaDailyList,
  required bool searchByDocument, //true=buscar por documento. false=buscar por apellido
  required String value
}) async {

  await fetchDataNovaDaily(
    uri: searchByDocument
        ? '$uriNovaDailyFindPartnerDocument=$value'
        : '$uriNovaDailyFindPartnerLastname=$value',
    value: value,
    classObject: PartnerNovaDailyDTO.empty(),
  ).then((data) {
      partnerNovaDailyList.clear();
      partnerNovaDailyList.addAll(data.cast<PartnerNovaDailyDTO>().map((e) =>
          PartnerNovaDailyDTO(
            partnerId: e.partnerId,
            name: e.name,
            lastname: e.lastname,
            document: e.document,
            paymentNumber: e.paymentNumber,
            telephone: e.telephone,
            address: e.address,
            birthDate: e.birthDate,
            addDate: e.addDate,
            updateDate: e.updateDate,
            deleteDate: e.deleteDate,
            notes: e.notes,
          )
      ));
  }).onError((error, stackTrace) {
    if (kDebugMode) print(error);
    if (error is ErrorObject) {
      throw ErrorObject(statusCode: error.statusCode, message: error.message);
    } else {
      throw Exception(error);
    }
  });
}
