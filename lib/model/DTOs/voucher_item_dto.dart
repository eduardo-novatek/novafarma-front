import 'package:intl/intl.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/DTOs/role_dto.dart';

class VoucherItemDTO extends Deserializable<VoucherItemDTO> {
  final int? voucherItemId;
  final int? medicineId;
  final int? quantity;
  final double? unitPrice;
  //final bool? isFirst;

  VoucherItemDTO.empty():
    voucherItemId = null,
    medicineId = null,
    quantity = null,
    unitPrice = null
    //isFirst = null
  ;

  VoucherItemDTO({
    this.voucherItemId,
    this.medicineId,
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
