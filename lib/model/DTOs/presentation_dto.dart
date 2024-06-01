import 'package:novafarma_front/model/globals/deserializable.dart';

class PresentationDTO extends Deserializable<PresentationDTO> {
  final int? presentationId;
  final String? name;
  final int? quantity;
  final String? unitName;
  //final bool? isFirst;

  PresentationDTO.empty():
    presentationId = null,
    name = null,
    quantity = null,
    unitName = null
    //isFirst = null
  ;

  PresentationDTO({
    this.presentationId,
    this.name,
    this.quantity,
    this.unitName,
    //this.isFirst,
  });

  @override
  PresentationDTO fromJson(Map<String, dynamic> json) {
    return PresentationDTO(
      presentationId: json['presentationId'],
      name: json['name'],
      quantity: json['quantity'],
      unitName: json['unitName'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'presentationId': presentationId,
      'name': name,
      'quantity': quantity,
      'unitName': unitName,
    };
  }
}
