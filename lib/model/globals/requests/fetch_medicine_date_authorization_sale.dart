import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart' show strToDate;

import '../../DTOs/date_authorization_sale_dto.dart';
import '../constants.dart' show uriDteAuthorizationSale;
import 'fetch_data_object.dart';

Future<DateTime?> fetchMedicineDateAuthorizationSale({
  required int customerId,
  required int medicineId,
}) async {

  Future<DateTime?> date = Future.value();

  await fetchDataObject<DateAuthorizationSaleDTO>(
    uri: '$uriDteAuthorizationSale/$customerId/$medicineId',
    classObject: DateAuthorizationSaleDTO.empty(),

  ).then((data) {
    if (data.isEmpty) return Future.value(null);
    date = Future.value(strToDate(data.first as String));

  }).onError((error, stackTrace) {
    if (kDebugMode) print(error);
    throw Exception(error);
  });
  return date;
}
