import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

import 'customer_dto.dart';
import 'medicine_dto.dart';

class ControlledMedicationDTO extends Deserializable<ControlledMedicationDTO> {
  int? controlledMedicationId;
  CustomerDTO? customer;
  MedicineDTO? medicine;
  int? frequencyDays;
  int? toleranceDays;
  DateTime? lastSaleDate;

  ControlledMedicationDTO.empty():
    controlledMedicationId = 0,
    customer = null,
    medicine = null,
    frequencyDays = 0,
    toleranceDays = 0,
    lastSaleDate = null
  ;

    ControlledMedicationDTO({
      required this.controlledMedicationId,
      required this.customer,
      required this.medicine,
      required this.frequencyDays,
      required this.toleranceDays,
      required this.lastSaleDate,
    });

    @override
    ControlledMedicationDTO fromJson(Map<String, dynamic> json) {
    return ControlledMedicationDTO(
      controlledMedicationId: json['controlledMedicationId'],
      customer: json['customer']['customerId'],
      medicine: json['medicine']['medicineId'],
      frequencyDays: json['frequencyDays'],
      toleranceDays: json['toleranceDays'],
      lastSaleDate: strToDate(json['lastSaleDate']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'controlledMedicationId': controlledMedicationId,
      'customer': customer,
      'medicine': medicine,
      'frequencyDays': frequencyDays,
      'toleranceDays': toleranceDays,
      'lastSaleDate': lastSaleDate,
    };
  }

 /* @override
  String toString() {
    return name;
  }*/

}