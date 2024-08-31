import 'package:novafarma_front/model/DTOs/presentation_dto.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

import '../globals/tools/date_time.dart';

class NursingReportDTO extends Deserializable<NursingReportDTO> {
  DateTime? dateTime;
  String? medicine;
  double? quantity;
  double? unitPrice;

  NursingReportDTO.empty():
    dateTime = null,
    medicine = null,
    quantity = null,
    unitPrice = null
  ;

  NursingReportDTO({
    this.dateTime,
    this.medicine,
    this.quantity,
    this.unitPrice
  });

  @override
  NursingReportDTO fromJson(Map<String, dynamic> json) {
    return NursingReportDTO(
      dateTime: strToDateTime(json['dateTime']),
      medicine: json['medicine'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice']
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime,
      'medicine': medicine,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}
