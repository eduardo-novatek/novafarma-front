import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

class VoucherDTO1 extends Deserializable<VoucherDTO1> {
  int? voucherId;
  String? voucherNumber;
  DateTime? date;
  MovementTypeEnum? movementType;
  double? total;
  String? notes;

  VoucherDTO1.empty():
    voucherId = null,
    voucherNumber = null,
    date = null,
    movementType = null,
    total = null,
    notes = null
  ;

  VoucherDTO1({
    this.voucherId,
    this.voucherNumber,
    this.date,
    this.movementType,
    this.total,
    this.notes,
  });

  @override
  VoucherDTO1 fromJson(Map<String, dynamic> json) {
    return VoucherDTO1(
      voucherId: json['voucherId'],
      voucherNumber: json['voucherNumber'],
      date: strToDate(json['dateTime']),
      movementType: nameBDtoMovementTypeEnum(json['movementType']!),
      total: json['total'],
      notes: json['notes'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'voucherId': voucherId,
      'voucherNumber': voucherNumber,
      'date': date?.toIso8601String(),
      'movementType': movementType,
      'total': total,
      'notes': notes,
    };
  }
}
