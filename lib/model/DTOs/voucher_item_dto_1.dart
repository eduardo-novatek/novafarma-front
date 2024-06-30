import 'package:novafarma_front/model/globals/deserializable.dart';

import 'controlled_medication_dto1.dart';
import 'medicine_dto.dart';

class VoucherItemDTO1 extends Deserializable<VoucherItemDTO1> {
 MedicineDTO? medicine;
 double? quantity;
 double? unitPrice;

  VoucherItemDTO1.empty():
    medicine = null,
    quantity = null,
    unitPrice = null
  ;

  VoucherItemDTO1({
    this.medicine,
    this.quantity,
    this.unitPrice,
  });

  @override
  VoucherItemDTO1 fromJson(Map<String, dynamic> json) {
    return VoucherItemDTO1(
      medicine: json['medicineId'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'medicine': medicine?.toJson(),
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}
