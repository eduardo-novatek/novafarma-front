import 'package:novafarma_front/model/objects/error_object.dart';

import '../../DTOs/supplier_dto.dart';
import '../constants.dart' show uriSupplierFindAll;
import '../tools/fetch_data.dart';

Future<void> fetchSupplierList({
  required List<SupplierDTO> supplierList,
  String uri = uriSupplierFindAll,
}) async {
  supplierList.clear();
  await fetchData<SupplierDTO>(
    uri: uri,
    classObject: SupplierDTO.empty(),
  ).then((data) {
      supplierList.addAll(data.cast<SupplierDTO>().map((e) =>
          SupplierDTO(
            supplierId: e.supplierId,
            name: e.name,
            telephone1: e.telephone1,
            telephone2: e.telephone2,
            address: e.address,
            email: e.email,
            notes: e.notes,
          )
      ));
  }).onError((error, stackTrace) {
    if (error is ErrorObject) {
      throw error;
    }
    throw Exception(error);
  });
}
