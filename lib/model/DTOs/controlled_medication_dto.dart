import 'package:flutter/cupertino.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

class ControlledMedicationDTO extends Deserializable<ControlledMedicationDTO> {
  int? controlledMedicationId;
  int? customerId;
  int? medicineId;
  String? medicineName;
  String? customerName;
  int? frequencyDays;
  int? toleranceDays;
  DateTime? lastSaleDate;
  //final bool? isFirst;

  ControlledMedicationDTO.empty():
    controlledMedicationId = 0,
    customerId = 0,
    medicineId = 0,
    medicineName = null,
    customerName = null,
    frequencyDays = 0,
    toleranceDays = 0,
    lastSaleDate = null
    //isFirst = null,
  ;

    ControlledMedicationDTO({
      required this.controlledMedicationId,
      required this.customerId,
      required this.medicineId,
      required this.medicineName,
      this.customerName,
      required this.frequencyDays,
      required this.toleranceDays,
      required this.lastSaleDate,
      //this.isFirst,
    });

    @override
    ControlledMedicationDTO fromJson(Map<String, dynamic> json) {
    return ControlledMedicationDTO(
      controlledMedicationId: json['controlledMedicationId'],
      customerId: json['customerId'],
      medicineId: json['medicine']['medicineId'],
      medicineName: json['medicine']['name'],
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
      'medicineId': medicineId,
      'medicineName': medicineName,
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