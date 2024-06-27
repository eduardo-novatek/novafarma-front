import 'package:novafarma_front/model/globals/deserializable.dart';

class CustomerDTO extends Deserializable<CustomerDTO> {
  int? customerId;

  CustomerDTO({required this.customerId});

  CustomerDTO.empty(): customerId = 0;

  @override
  CustomerDTO fromJson(Map<String, dynamic> json) {
    return CustomerDTO(customerId: json['customerId']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'customerId': customerId};
  }

}