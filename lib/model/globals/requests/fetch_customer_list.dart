import '../../DTOs/customer_dto.dart';
import '../constants.dart' show uriCustomerFindAll;
import 'fetch_data_object.dart';

Future<void> fetchCustomerList(List<CustomerDTO> customerList) async {

  await fetchDataObject<CustomerDTO>(
    uri: uriCustomerFindAll,
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
    throw Exception(error);
  });
}
