import 'package:novafarma_front/model/DTOs/medicine_dto2.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

class ControlledMedicationDTO1 extends Deserializable<ControlledMedicationDTO1> {
  int? controlledMedicationId;
  int? customerId;
  //int? medicineId;
  //String? medicineName;
  MedicineDTO2? medicine;
  String? customerName;
  int? frequencyDays;
  int? toleranceDays;
  DateTime? lastSaleDate;
  //final bool? isFirst;

  ControlledMedicationDTO1.empty():
    controlledMedicationId = 0,
    customerId = 0,
    //medicineId = 0,
    //medicineName = null,
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
      //required this.medicineId,
      //required this.medicineName,
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
      //medicineId: json['medicine']['medicineId'],
      //medicineName: json['medicine']['name'],
      medicine: medicine?.fromJson(json['medicine']),
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
      //'medicineId': medicineId,
      //'medicineName': medicineName,
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