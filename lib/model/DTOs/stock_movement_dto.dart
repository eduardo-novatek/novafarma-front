import 'package:novafarma_front/model/DTOs/voucher_item_dto_3.dart';
import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

import 'medicine_dto.dart';

class StockMovementDTO extends Deserializable<StockMovementDTO> {
  int? stockMovementId;
  DateTime? dateTime;
  MovementTypeEnum? movementType;
  double? quantity;
  double? unitPrice;
  MedicineDTO medicine;
  VoucherItemDTO3 voucherItem;

  StockMovementDTO.empty():
    stockMovementId = null,
    dateTime = null,
    movementType = null,
    quantity = null,
    unitPrice = null,
    medicine = MedicineDTO.empty(),
    voucherItem = VoucherItemDTO3.empty()
  ;

    StockMovementDTO({
      required this.stockMovementId,
      required this.dateTime,
      required this.movementType,
      required this.quantity,
      required this.unitPrice,
      required this.medicine,
      required this.voucherItem,
    });

    @override
    StockMovementDTO fromJson(Map<String, dynamic> json) {
    return StockMovementDTO(
      stockMovementId: json['stockMovementId'],
      dateTime: strToDateTime(json['dateTime']),
      movementType: nameDBtoMovementTypeEnum(json['movementType']),
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      medicine: medicine.fromJson(json),
      voucherItem: voucherItem.fromJson(json)
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'stockMovementId': stockMovementId,
      'dateTime': dateTime,
      'movementType': movementType,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'medicine': medicine,
      'voucherItem': voucherItem
    };
  }

 /* @override
  String toString() {
    return name;
  }*/

}