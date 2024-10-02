import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/DTOs/dependent_nova_daily_dto.dart';
import 'package:novafarma_front/model/globals/requests/fetch_data_nova_daily.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../constants.dart' show hostNovaDaily, novaDailyToken, portNovaDaily,
  uriNovaDailyFindDependentDocument, uriNovaDailyFindDependentLastname,
  uriProxyCORSNovaDaily;

/// searchByDocument: true=buscar por documento. false=buscar por apellido
Future<void> fetchDependentNovaDailyList({
  required List<DependentNovaDailyDTO> dependentNovaDailyList,
  required bool searchByDocument, // true=buscar por documento. false=buscar por apellido
  required String value,
}) async {

  final queryParamKey = searchByDocument ? 'cedula' : 'apellido';
  final url = Uri(
    scheme: 'http',
    host: hostNovaDaily,
    port: portNovaDaily,
    path: searchByDocument
        ? uriNovaDailyFindDependentDocument
        : uriNovaDailyFindDependentLastname,
    queryParameters: {
      'apiToken': novaDailyToken,
      queryParamKey: value,
    },
  );
  await fetchDataNovaDaily(
    uri: Uri.parse('$uriProxyCORSNovaDaily${url.toString()}'),
    classObject: DependentNovaDailyDTO.empty(),
  ).then((data) {
    if (data[0] == "null") return null;
    dependentNovaDailyList.clear();
    dependentNovaDailyList.addAll(
      data.cast<DependentNovaDailyDTO>().map((e) => DependentNovaDailyDTO(
        dependentId: e.dependentId,
        name: e.name,
        lastname: e.lastname,
        document: e.document,
        partnerNovaDaily: e.partnerNovaDaily,
      )),
    );
  }).onError((error, stackTrace) {
    if (kDebugMode) print(error);
    if (error is ErrorObject) {
      if (error.statusCode == 0) return null; //No encontrado
      throw ErrorObject(statusCode: error.statusCode, message: error.message);
    } else {
      throw Exception(error);
    }
  });
}
