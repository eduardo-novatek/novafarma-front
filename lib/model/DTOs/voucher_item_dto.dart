import 'package:novafarma_front/model/globals/deserializable.dart';

class VoucherItemDTO extends Deserializable<VoucherItemDTO> {
  int? voucherItemId;
  int? medicineId;
  String? barCode;
  String? medicineName;
  double? currentStock;
  String? presentation;
  int? quantity;
  double? unitPrice;
  //final bool? isFirst;

  VoucherItemDTO.empty():
    voucherItemId = null,
    medicineId = null,
    barCode = null,
    medicineName = null,
    presentation = null,
    quantity = null,
    unitPrice = null,
    currentStock = null
    //isFirst = null
  ;

  VoucherItemDTO({
    this.voucherItemId,
    this.medicineId,
    this.barCode,
    this.medicineName,
    this.presentation,
    this.quantity,
    this.unitPrice,
    this.currentStock,
    //this.isFirst,
  });

  @override
  VoucherItemDTO fromJson(Map<String, dynamic> json) {
    return VoucherItemDTO(
      voucherItemId: json['voucherItemId'],
      medicineId: json['medicineId'],
      barCode: json['barCode'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'voucherItemId': voucherItemId,
      'medicineId': medicineId,
      'barCode': barCode,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'currentStock': currentStock,
    };
  }
}
