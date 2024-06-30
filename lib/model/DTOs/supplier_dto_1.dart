import 'package:novafarma_front/model/globals/deserializable.dart';

class SupplierDTO1 extends Deserializable<SupplierDTO1> {
  int? supplierId;

  SupplierDTO1({required this.supplierId});

  SupplierDTO1.empty(): supplierId = 0;

  @override
  SupplierDTO1 fromJson(Map<String, dynamic> json) {
    return SupplierDTO1(supplierId: json['supplierId']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'supplierId': supplierId};
  }

}