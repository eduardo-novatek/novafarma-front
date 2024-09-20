import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart' show
  strToDateTime;

class VoucherDTO1 extends Deserializable<VoucherDTO1> {
  int? voucherId;
  String? voucherNumber;
  DateTime? dateTime;
  MovementTypeEnum? movementType;
  double? total;
  String? notes;

  VoucherDTO1.empty():
    voucherId = null,
    voucherNumber = null,
    dateTime = null,
    movementType = null,
    total = null,
    notes = null
  ;

  VoucherDTO1({
    this.voucherId,
    this.voucherNumber,
    this.dateTime,
    this.movementType,
    this.total,
    this.notes,
  });

  @override
  VoucherDTO1 fromJson(Map<String, dynamic> json) {
    return VoucherDTO1(
      voucherId: json['voucherId'],
      voucherNumber: json['voucherNumber'],
      dateTime: strToDateTime(json['dateTime']),
      movementType: nameDBtoMovementTypeEnum(json['movementTypeEnum']!),
      total: json['total'],
      notes: json['notes'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'voucherId': voucherId,
      'voucherNumber': voucherNumber,
      'date': dateTime?.toIso8601String(),
      'movementTypeEnum': movementType,
      'total': total,
      'notes': notes,
    };
  }
}
