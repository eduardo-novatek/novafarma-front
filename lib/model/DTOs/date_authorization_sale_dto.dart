import 'package:novafarma_front/model/globals/deserializable.dart';

class DateAuthorizationSaleDTO extends Deserializable<DateAuthorizationSaleDTO> {
  String? dateAuthorization;
  //final bool? isFirst;

  DateAuthorizationSaleDTO.empty():
    dateAuthorization = null
    //isFirst = null
  ;

  DateAuthorizationSaleDTO({
    this.dateAuthorization,
    //this.isFirst,
  });

  @override
  DateAuthorizationSaleDTO fromJson(Map<String, dynamic> json) {
    return DateAuthorizationSaleDTO(
      dateAuthorization: json['dateAuthorization'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'dateAuthorization': dateAuthorization,
    };
  }
}
