import 'package:novafarma_front/model/globals/deserializable.dart';

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
