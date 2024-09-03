import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

class PartnerNovaDailyDTO extends Deserializable<PartnerNovaDailyDTO> {
  int? partnerId;
  String? name;
  String? lastname;
  int? document;
  int? paymentNumber;
  String? telephone;
  String? address;
  String? birthDate;
  String? addDate;
  String? updateDate;
  String? deleteDate;
  String? notes;

  PartnerNovaDailyDTO.empty():
      partnerId = null,
      name = null,
      lastname = null ,
      document = null,
      paymentNumber = null,
      telephone = null,
      address = null,
      birthDate = null,
      addDate = null,
      updateDate = null,
      deleteDate = null,
      notes = null
  ;

  PartnerNovaDailyDTO({
    this.partnerId,
    this.name,
    this.lastname,
    this.document,
    this.paymentNumber,
    this.telephone,
    this.address,
    this.birthDate,
    this.addDate,
    this.updateDate,
    this.deleteDate,
    this.notes,
  });

  @override
  PartnerNovaDailyDTO fromJson(Map<String, dynamic> json) {
    return PartnerNovaDailyDTO(
      partnerId: json['id'],
      name: json['nombre'],
      lastname: json['apellido'],
      document: int.parse(json['cedula']),
      paymentNumber: json['numeroCobro'] != ''
          ? int.parse(json['numeroCobro'])
          : 0,
      telephone: json['telefono'],
      address: json['direccion'],
      birthDate: strDateToStrDateView(json['fechaNacimiento']),
      addDate: strYMDHMToStrDMY(json['fechaAlta']),
      updateDate: strYMDHMToStrDMY(json['fechaModificacion']),
      deleteDate: strYMDHMToStrDMY(json['fechaBaja']),
      notes: json['notas'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': partnerId,
      'nombre': name,
      'apellido': lastname,
      'cedula': document,
      'numeroCobro': paymentNumber,
      'telefono': telephone,
      'direccion': address,
      'fechaNacimiento': birthDate,
      'fechaAlta': addDate,
      'fechaModificacion': updateDate,
      'fechaBaja': deleteDate,
      'notas': notes,
    };
  }
}
