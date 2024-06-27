import 'package:novafarma_front/model/globals/deserializable.dart';

class MedicineDTO extends Deserializable<MedicineDTO> {
  int? medicineId;

  MedicineDTO({required this.medicineId});

  MedicineDTO.empty(): medicineId = 0;

  @override
  MedicineDTO fromJson(Map<String, dynamic> json) {
    return MedicineDTO(medicineId: json['medicineId']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'medicineId': medicineId};
  }

}