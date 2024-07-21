import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../DTOs/customer_dto1.dart';
import '../constants.dart' show uriCustomerFindDocument, uriCustomerFindLastnameName;
import '../tools/fetch_data.dart';

/// searchByDocument: true=buscar por documento. false=buscar por apellido
Future<void> fetchCustomerList({
  required List<CustomerDTO1> customerList,
  required bool searchByDocument, //true=buscar por documento. false=buscar por apellido
  required String value
}) async {

  await fetchData<CustomerDTO1>(
    uri: searchByDocument
        ? '$uriCustomerFindDocument/$value'
        : '$uriCustomerFindLastnameName/$value',
    classObject: CustomerDTO1.empty(),
  ).then((data) {
      customerList.clear();
      customerList.addAll(data.cast<CustomerDTO1>().map((e) =>
          CustomerDTO1(
            customerId: e.customerId,
            name: e.name,
            lastname: e.lastname,
            document: e.document,
            telephone: e.telephone,
            paymentNumber: e.paymentNumber,
            addDate: e.addDate,
            partner: e.partner,
            deleted: e.deleted,
            partnerId: e.partnerId,
            dependentId: e.dependentId,
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
