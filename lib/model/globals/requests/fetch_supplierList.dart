import 'package:flutter/cupertino.dart';

import '../../DTOs/supplier_dto.dart';
import '../constants.dart' show uriSupplierFindAll, defaultTextFromDropdownMenu;
import 'fetch_data_object.dart';

Future<void> fetchSupplierList(List<SupplierDTO> supplierList) async {

  fetchDataObject<SupplierDTO>(
    uri: uriSupplierFindAll,
    classObject: SupplierDTO.empty(),

  ).then((data) {
      supplierList.clear();
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
      supplierList.insert(
          0,
          SupplierDTO(
              name: defaultTextFromDropdownMenu, supplierId: 0, isFirst: true
          )
      );
      // _loading = false;

  }).onError((error, stackTrace) {
    throw Exception(error);
  });
}
