import 'package:novafarma_front/model/globals/deserializable.dart';

class VoucherItemDTO extends Deserializable<VoucherItemDTO> {
  final int? voucherItemId;
  final int? medicineId;
  final String? medicineName;
  late final int? quantity;
  final double? unitPrice;
  //final bool? isFirst;

  VoucherItemDTO.empty():
    voucherItemId = null,
    medicineId = null,
    medicineName = null,
    quantity = null,
    unitPrice = null
    //isFirst = null
  ;

  VoucherItemDTO({
    this.voucherItemId,
    this.medicineId,
    this.medicineName,
    this.quantity,
    this.unitPrice,
    //this.isFirst,
  });

  @override
  VoucherItemDTO fromJson(Map<String, dynamic> json) {
    return VoucherItemDTO(
      voucherItemId: json['voucherItemId'],
      medicineId: json['medicineId'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voucherItemId': voucherItemId,
      'medicineId': medicineId,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}
