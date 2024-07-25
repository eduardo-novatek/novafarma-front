import 'package:novafarma_front/model/globals/deserializable.dart';

class VoucherDTO1 extends Deserializable<VoucherDTO1> {
  int? voucherId;
  String? voucherNumber;
  DateTime? date;
  int? movementType;
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
      date: json['date'],
      movementType: json['movementType'],
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
