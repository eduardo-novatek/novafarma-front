import 'package:novafarma_front/model/DTOs/presentation_dto.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

class MedicineDTO2 extends Deserializable<MedicineDTO2> {
  int? medicineId;
  PresentationDTO? presentation;
  String? name;
  bool? controlled;
  bool? deleted;

  MedicineDTO2({
    this.medicineId,
    this.presentation,
    this.name,
    this.controlled,
    this.deleted
  });

  MedicineDTO2.empty():
    medicineId = null,
    presentation = null,
    name = null,
    controlled = null,
    deleted = null;

  @override
  MedicineDTO2 fromJson(Map<String, dynamic> json) {
    return MedicineDTO2(
      medicineId: json['medicineId'],
      presentation: PresentationDTO().fromJson(json['presentation']),
      name: json['name'],
      controlled: json['controlled'],
      deleted: json['deleted'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'presentation': presentation,
      'name': name,
      'controlled': controlled,
      'deleted': deleted,
    };
  }

}