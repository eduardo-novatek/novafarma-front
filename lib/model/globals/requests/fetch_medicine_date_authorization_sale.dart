import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../DTOs/date_authorization_sale_dto.dart';
import '../constants.dart' show uriDteAuthorizationSale;
import '../tools/parse_date.dart';
import 'fetch_data_object.dart';

Future<DateTime?> fetchMedicineDateAuthorizationSale({
  required int customerId,
  required int medicineId,
}) async {

  await fetchDataObject<DateAuthorizationSaleDTO>(
    uri: '$uriDteAuthorizationSale/$customerId/$medicineId',
    classObject: DateAuthorizationSaleDTO.empty(),
  ).then((data) {
    if (data.isNotEmpty) {
      final DateAuthorizationSaleDTO fetchDateAuth = data.first as DateAuthorizationSaleDTO;
      if (fetchDateAuth.dateAuthorization == null) return Future.value(null);
      return Future.value(parseDate(fetchDateAuth.dateAuthorization!));
    }
  }).onError((error, stackTrace) {
    if (kDebugMode) print(error);
    throw Exception(error);
  });
  return null;
}
