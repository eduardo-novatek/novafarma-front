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
      document: json['cedula'] is String
          ? int.parse(json['cedula'])
          : json['cedula'],
      paymentNumber: json['numeroCobro'] != ''
          ? json['numeroCobro'] is String
            ? int.parse(json['numeroCobro'])
            : json['numeroCobro']
          : 0,
      telephone: json['telefono'],
      address: json['direccion'],
      birthDate: _dateConvert(json['fechaNacimiento']),
      addDate: _dateConvert1(json['fechaAlta']),
      updateDate: _dateConvert1(json['fechaModificacion']),
      deleteDate: _dateConvert1(json['fechaBaja']),
      notes: json['notas'],
    );
  }

  String? _dateConvert(String? date) {
    try {
      //Intenta devolver la fecha formateada (en caso que date sea YMD)
      return strDateToStrDateView(date);
    } catch (e) {
      //No pudo convertir, con lo cual la fecha ya esta casteada a DMA
      return date;
    }
  }

  String? _dateConvert1(String? date) {
    String? ret = strYMDHMToStrDMY(date);
    return ret ?? date;
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
