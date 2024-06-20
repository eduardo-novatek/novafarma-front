import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

class CustomerDTO extends Deserializable<CustomerDTO> {
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

  CustomerDTO.empty():
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

  CustomerDTO({
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
  CustomerDTO fromJson(Map<String, dynamic> json) {
    return CustomerDTO(
      customerId: json['customerId'],
      name: json['name'],
      lastname: json['lastname'],
      document: json['document'],
      telephone: json['telephone'],
      //addDate: DateFormat("dd/MM/yyyy").parse(json['addDate']),
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
