
import 'package:novafarma_front/model/DTOs/supplier_dto_1.dart';
import 'package:novafarma_front/model/DTOs/user_dto_1.dart';
import 'package:novafarma_front/model/DTOs/voucher_item_dto_1.dart';
import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

import '../globals/tools/date_time.dart';
import 'customer_dto.dart';

class VoucherDTO extends Deserializable<VoucherDTO> {
  int? voucherId;
  MovementTypeEnum? movementType;
  String? voucherNumber; //En caso de numeracion manual
  UserDTO1? user;
  CustomerDTO? customer;
  SupplierDTO1? supplier;
  DateTime? dateTime;
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
    this.total,
    this.voucherItemList,
  });

  @override
  VoucherDTO fromJson(Map<String, dynamic> json) {
    return VoucherDTO(
      voucherId: json['voucherId'],
      movementType: json['movementType'],
      voucherNumber: json['voucherNumber'],
      user: json['user']['userId'],
      customer: json['customer']['customerId'],
      supplier: json['supplier']['supplierId'],
      dateTime: strToDate(json['dateTime']),
      total: json['total'],
      voucherItemList: json['voucherItemList'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'voucherId': voucherId,
      'movementType': movementType,
      'voucherNumber': voucherNumber,
      'user': user,
      'customer': customer,
      'supplier': supplier,
      'dateTime': dateTime,
      'total': total,
      'voucherItemList': voucherItemList,
    };
  }
}
