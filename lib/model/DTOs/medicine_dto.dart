import 'package:novafarma_front/model/globals/deserializable.dart';

class MedicineDTO extends Deserializable<MedicineDTO> {
  final int? medicineId;
  final PresentationDTO? presentation;
  final String? name;
  final DateTime? lastAddDate;
  final double? lastCostPrice;
  final double? lastSalePrice;
  final int? currentStock;
  final bool? controlled;

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
    return MedicineDTO(
      medicineId: json['medicineId'],
      presentation: json['presentation'],
      name: json['name'],
      lastAddDate: json['lastAddDate'],
      lastCostPrice: json['lastCostPrice'],
      lastSalePrice: json['lastSalePrice'],
      currentStock: json['currentStock'],
      controlled: json['controlled'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
    };
  }
}
