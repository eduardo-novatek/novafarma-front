import 'package:novafarma_front/model/globals/tools/date_time.dart' show strToDate;

import '../../DTOs/date_authorization_sale_dto.dart';
import '../constants.dart' show uriDateAuthorizationSale;
import '../tools/fetch_data.dart';

Future<DateTime?> fetchMedicineDateAuthorizationSale({
  required int customerId,
  required int medicineId,
}) async {

  Future<DateTime?> date = Future.value();

  await fetchData<DateAuthorizationSaleDTO>(
    uri: '$uriDateAuthorizationSale/$customerId/$medicineId',
    classObject: DateAuthorizationSaleDTO.empty(),

  ).then((data) {
    //Si data es vacio, implica que es la primera venta (el medicamento
    // controlado esta registrado para el cliente)
    if (data.isEmpty) return Future.value(null);
    date = Future.value(strToDate(data.first as String));

  }).onError((error, stackTrace) {
    return Future.error(error!);
  });
  return date;
}
