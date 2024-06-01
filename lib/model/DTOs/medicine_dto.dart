import 'package:intl/intl.dart';
import 'package:novafarma_front/model/DTOs/presentation_dto.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

import '../globals/tools/parse_date.dart';

class MedicineDTO extends Deserializable<MedicineDTO> {
  int? medicineId;
  PresentationDTO? presentation;
  String? name;
  DateTime? lastAddDate;
  double? lastCostPrice;
  double? lastSalePrice;
  int? currentStock;
  bool? controlled;

  //final bool? isFirst;

  MedicineDTO.empty():
    medicineId = null,
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
      presentation: json['presentation'] != null
        ? PresentationDTO().fromJson(json['presentation'])
        : null,
      name: json['name'],
      lastAddDate: parseDate(json['lastAddDate']),
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
