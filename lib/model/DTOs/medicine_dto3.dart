import 'package:novafarma_front/model/DTOs/presentation_dto.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

class MedicineDTO3 extends Deserializable<MedicineDTO3> {
  int? medicineId;
  PresentationDTO? presentation;
  String? name;
  bool? controlled;

  MedicineDTO3({
    this.medicineId,
    this.presentation,
    this.name,
    this.controlled
  });

  MedicineDTO3.empty():
    medicineId = null,
    presentation = null,
    name = null,
    controlled = null;

  @override
  MedicineDTO3 fromJson(Map<String, dynamic> json) {
    return MedicineDTO3(
      medicineId: json['medicineId'],
      presentation: PresentationDTO().fromJson(json['presentation']),
      name: json['name'],
      controlled: json['controlled']
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'presentation': presentation,
      'name': name,
      'controlled': controlled,
    };
  }

}