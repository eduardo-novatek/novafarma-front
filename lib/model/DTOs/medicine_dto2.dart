import 'package:novafarma_front/model/globals/deserializable.dart';

class MedicineDTO2 extends Deserializable<MedicineDTO2> {
  int? medicineId;
  String? name;

  MedicineDTO2({this.medicineId, this.name});

  MedicineDTO2.empty():
    medicineId = 0,
    name = null;

  @override
  MedicineDTO2 fromJson(Map<String, dynamic> json) {
    return MedicineDTO2(
      medicineId: json['medicineId'],
      name: json['name'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'name': name,
    };
  }

}