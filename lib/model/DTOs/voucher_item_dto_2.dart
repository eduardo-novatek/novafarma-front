import 'package:novafarma_front/model/globals/deserializable.dart';

import 'medicine_dto2.dart';

class VoucherItemDTO2 extends Deserializable<VoucherItemDTO2> {
  int? voucherItemId;
  MedicineDTO2? medicine;
  double? quantity;
  double? unitPrice;

  VoucherItemDTO2.empty():
    voucherItemId = null,
    medicine = null,
    quantity = null,
    unitPrice = null
  ;

  VoucherItemDTO2({
    this.voucherItemId,
    this.medicine,
    this.quantity,
    this.unitPrice,
  });

  @override
  VoucherItemDTO2 fromJson(Map<String, dynamic> json) {
    return VoucherItemDTO2(
      voucherItemId: json['voucherItemId'],
      medicine: MedicineDTO2().fromJson(json['medicine']),
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'voucherItemId': voucherItemId,
      'medicine': medicine?.toJson(),
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}
