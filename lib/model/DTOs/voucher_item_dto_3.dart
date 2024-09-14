import 'package:novafarma_front/model/globals/deserializable.dart';

class VoucherItemDTO3 extends Deserializable<VoucherItemDTO3> {
  int? voucherItemId;

  VoucherItemDTO3.empty():
    voucherItemId = null
  ;

  VoucherItemDTO3({
    this.voucherItemId,
  });

  @override
  VoucherItemDTO3 fromJson(Map<String, dynamic> json) {
    return VoucherItemDTO3(
      voucherItemId: json['voucherItemId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'voucherItemId': voucherItemId,
    };
  }
}
