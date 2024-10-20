
import 'package:flutter/cupertino.dart';
import 'package:novafarma_front/model/DTOs/customer_dto1.dart';
import 'package:novafarma_front/model/globals/handleError.dart';

import '../../enums/request_type_enum.dart';
import '../constants.dart' show uriCustomerAdd, uriCustomerUpdate;
import '../tools/fetch_data_object.dart';

///Devuelve el id del cliente persistido o id=0 si hubo un error
Future<int?> addOrUpdateCustomer({
  required CustomerDTO1 customer,
  required bool isAdd,
  required BuildContext context}) async {

  int id = 0; //id del cliente persistido

  await fetchDataObject(
      uri: isAdd ? uriCustomerAdd : uriCustomerUpdate,
      classObject: customer,
      requestType: isAdd ? RequestTypeEnum.post : RequestTypeEnum.patch,
      body: customer

  ).then((customerId) {
    id = customerId.isNotEmpty ? customerId[0] as int : customer.customerId!;

  }).onError((error, stackTrace) {
    handleError(error: error, context: context);
    return Future.error(0);
  });
  return Future.value(id);
}