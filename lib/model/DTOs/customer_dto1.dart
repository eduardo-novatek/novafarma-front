import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

class CustomerDTO1 extends Deserializable<CustomerDTO1> {
  int? customerId;
  String name;
  String? lastname;
  int? document;
  String? telephone;
  DateTime? addDate;
  int? paymentNumber;
  bool? partner;
  bool? deleted;
  String? notes;
  int? partnerId;
  int? dependentId;
  bool? isFirst;

  CustomerDTO1.empty():
      customerId = null,
      name = "",
      lastname = null ,
      document = null,
      telephone = null,
      addDate = null,
      paymentNumber = null,
      partner = null,
      deleted = null,
      notes = null,
      partnerId = null,
      dependentId = null,
      isFirst = null
  ;

  CustomerDTO1({
    this.customerId,
    this.lastname,
    this.document,
    this.telephone,
    this.addDate,
    this.paymentNumber,
    this.partner,
    this.deleted,
    this.notes,
    this.partnerId,
    this.dependentId,
    this.isFirst,
    required this.name,
  });

  @override
  CustomerDTO1 fromJson(Map<String, dynamic> json) {
    return CustomerDTO1(
      customerId: json['customerId'],
      name: json['name'],
      lastname: json['lastname'],
      document: json['document'],
      telephone: json['telephone'],
      addDate: strToDate(json['addDate']),
      paymentNumber: json['paymentNumber'],
      partner: json['partner'],
      deleted: json['deleted'],
      notes: json['notes'],
      partnerId: json['partnerId'],
      dependentId: json['dependentId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'name': name,
      'lastname': lastname,
      'document': document,
      'telephone': telephone,
      'addDate': addDate,
      'paymentNumber': paymentNumber,
      'partner': partner,
      'deleted': deleted,
      'notes': notes,
      'partnerId': partnerId,
      'dependentId': dependentId,
    };
  }
}
