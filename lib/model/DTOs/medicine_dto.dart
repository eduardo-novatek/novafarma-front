import 'package:novafarma_front/model/DTOs/presentation_dto.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

import '../globals/tools/date_time.dart';

class MedicineDTO extends Deserializable<MedicineDTO> {
  int? medicineId;
  String? barCode;
  PresentationDTO? presentation;
  String? name;
  DateTime? lastAddDate;
  double? lastCostPrice;
  double? lastSalePrice;
  double? currentStock;
  bool? controlled;

  //final bool? isFirst;

  MedicineDTO.empty():
    medicineId = null,
    barCode = null,
    presentation = null,
    name = null,
    lastAddDate = null,
    lastCostPrice = null,
    lastSalePrice =  null,
    currentStock = null,
    controlled =  null
    //isFirst = null
  ;

  MedicineDTO({
    this.medicineId,
    this.barCode,
    this.presentation,
    this.name,
    this.lastAddDate,
    this.lastCostPrice,
    this.lastSalePrice,
    this.currentStock,
    this.controlled,
    //this.isFirst,
  });

  @override
  MedicineDTO fromJson(Map<String, dynamic> json) {
    MedicineDTO m = MedicineDTO(
      medicineId: json['medicineId'],
      barCode: json['barCode'],
      presentation: json['presentation'] != null
        ? PresentationDTO().fromJson(json['presentation'])
        : null,
      name: json['name'],
      lastAddDate: toDate(json['lastAddDate']),
      lastCostPrice: json['lastCostPrice'],
      lastSalePrice: json['lastSalePrice'],
      currentStock: json['currentStock'],
      controlled: json['controlled'],
    );
    return m;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'barCode': barCode,
      'presentation': presentation,
      'name': name,
      'lastAddDate': lastAddDate,
      'lastCostPrice': lastCostPrice,
      'lastSalePrice': lastSalePrice,
      'currentStock': currentStock,
      'controlled': controlled,
    };
  }
}
