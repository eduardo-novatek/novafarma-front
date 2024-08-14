import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

import 'medicine_dto2.dart';

class ControlledMedicationDTO1 extends Deserializable<ControlledMedicationDTO1> {
  int? controlledMedicationId;
  int? customerId;
  MedicineDTO2? medicine;
  String? customerName;
  int? frequencyDays;
  int? toleranceDays;
  DateTime? lastSaleDate;
  //final bool? isFirst;

  ControlledMedicationDTO1.empty():
    controlledMedicationId = 0,
    customerId = 0,
    medicine = null,
    customerName = null,
    frequencyDays = 0,
    toleranceDays = 0,
    lastSaleDate = null
    //isFirst = null,
  ;

    ControlledMedicationDTO1({
      required this.controlledMedicationId,
      required this.customerId,
      required this.medicine,
      this.customerName,
      required this.frequencyDays,
      required this.toleranceDays,
      required this.lastSaleDate,
      //this.isFirst,
    });

    @override
    ControlledMedicationDTO1 fromJson(Map<String, dynamic> json) {
    return ControlledMedicationDTO1(
      controlledMedicationId: json['controlledMedicationId'],
      customerId: json['customerId'],
      medicine: MedicineDTO2().fromJson(json['medicine']),
      frequencyDays: json['frequencyDays'],
      toleranceDays: json['toleranceDays'],
      lastSaleDate: strToDate(json['lastSaleDate']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'controlledMedicationId': controlledMedicationId,
      'customerId': customerId,
      'medicine': medicine,
      'customerName': customerName,
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