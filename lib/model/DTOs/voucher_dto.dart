
import 'package:novafarma_front/model/DTOs/supplier_dto_1.dart';
import 'package:novafarma_front/model/DTOs/user_dto_1.dart';
import 'package:novafarma_front/model/DTOs/voucher_item_dto_1.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

import '../globals/tools/date_time.dart';
import 'customer_dto.dart';

class VoucherDTO extends Deserializable<VoucherDTO> {
  int? voucherId;
  int? movementType;
  String? voucherNumber; //En caso de numeracion manual
  UserDTO1? user;
  CustomerDTO? customer;
  SupplierDTO1? supplier;
  DateTime? dateTime;
  String? notes;
  double? total;
  List<VoucherItemDTO1>? voucherItemList;

  VoucherDTO.empty():
    voucherId = null,
    movementType = null,
    voucherNumber = null,
    user = null,
    customer = null,
    supplier = null,
    dateTime = null,
    notes = null,
    total = null,
    voucherItemList = null
  ;

  VoucherDTO({
    this.voucherId,
    this.movementType,
    this.voucherNumber,
    this.user,
    this.customer,
    this.supplier,
    this.dateTime,
    this.notes,
    this.total,
    this.voucherItemList,
  });

  @override
  VoucherDTO fromJson(Map<String, dynamic> json) {
    return VoucherDTO(
      voucherId: json['voucherId'],
      movementType: json['movementTypeEnum'],
      voucherNumber: json['voucherNumber'],
      user: json['user']['userId'],
      customer: json['customer']['customerId'],
      supplier: json['supplier']['supplierId'],
      dateTime: strToDate(json['dateTime']),
      notes: json['notes'],
      total: json['total'],
      voucherItemList: json['voucherItemList'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'voucherId': voucherId,
      'movementTypeEnum': movementType,
      'voucherNumber': voucherNumber,
      'user': user?.toJson(),
      'customer': customer?.toJson(),
      'supplier': supplier?.toJson(),
      'dateTime': dateTime?.toIso8601String(),
      'notes': notes,
      'total': total,
      'voucherItemList': voucherItemList?.map((item) => item.toJson()).toList(),
    };
  }
}
