import 'package:novafarma_front/model/DTOs/user_dto_1.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

class CustomerDTO2 extends Deserializable<CustomerDTO2> {
  int? document;
  String? name;

  CustomerDTO2.empty():
      document = null,
      name = ""
  ;

  CustomerDTO2({
    this.document,
    this.name,
  });

  @override
  CustomerDTO2 fromJson(Map<String, dynamic> json) {
    return CustomerDTO2(
      document: json['document'],
      name: json['name'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'document': document,
    };
  }
}
