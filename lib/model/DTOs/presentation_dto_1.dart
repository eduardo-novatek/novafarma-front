import 'package:novafarma_front/model/DTOs/unit_dto_1.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

class PresentationDTO1 extends Deserializable<PresentationDTO1> {
  int? presentationId;
  String? name;
  int? quantity;
  UnitDTO1? unit;
  //final bool? isFirst;

  PresentationDTO1.empty():
    presentationId = null,
    name = null,
    quantity = null,
    unit = null
    //isFirst = null
  ;

  PresentationDTO1({
    this.presentationId,
    this.name,
    this.quantity,
    this.unit,
    //this.isFirst,
  });

  @override
  PresentationDTO1 fromJson(Map<String, dynamic> json) {
    return PresentationDTO1(
      presentationId: json['presentationId'],
      name: json['name'],
      quantity: json['quantity'],
      unit: unit?.fromJson(json['unit']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'presentationId': presentationId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}
