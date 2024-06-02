import 'package:flutter/foundation.dart';

import '../../DTOs/customer_dto.dart';
import '../constants.dart' show uriCustomerFindDocument, uriCustomerFindLastnameName;
import 'fetch_data_object.dart';

Future<void> fetchCustomerList({
  required List<CustomerDTO> customerList,
  required bool searchByDocument, //true=buscar por documento. false=buscar por apellido
  required String value
}) async {

  await fetchDataObject<CustomerDTO>(
    uri: searchByDocument
        ? '$uriCustomerFindDocument/$value'
        : '$uriCustomerFindLastnameName/$value',
    classObject: CustomerDTO.empty(),
  ).then((data) {
      customerList.clear();
      customerList.addAll(data.cast<CustomerDTO>().map((e) =>
          CustomerDTO(
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
    throw Exception(error);
  });
}
