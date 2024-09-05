import 'package:novafarma_front/model/DTOs/partner_nova_daily_dto.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

class DependentNovaDailyDTO extends Deserializable<DependentNovaDailyDTO> {
  int? dependentId;
  String? name;
  String? lastname;
  int? document;
  PartnerNovaDailyDTO? partnerNovaDaily;

  DependentNovaDailyDTO.empty():
      dependentId = null,
      name = null,
      lastname = null ,
      document = null,
      partnerNovaDaily = null
  ;

  DependentNovaDailyDTO({
    this.dependentId,
    this.name,
    this.lastname,
    this.document,
    this.partnerNovaDaily,
  });

  @override
  DependentNovaDailyDTO fromJson(Map<String, dynamic> json) {
    return DependentNovaDailyDTO(
      dependentId: json['id'],
      name: json['nombre'],
      lastname: json['apellido'],
      document: int.tryParse(json['cedula']),
      partnerNovaDaily: PartnerNovaDailyDTO(
        partnerId: json['idSocio']['id'],
        name: json['idSocio']['nombre'],
        lastname: json['idSocio']['apellido'],
        document: int.tryParse(json['idSocio']['cedula']),
        paymentNumber: json['idSocio']['numeroCobro'] != ''
          ? int.parse(json['idSocio']['numeroCobro'])
          : 0,
        telephone: json['idSocio']['telefono'],
        address: json['idSocio']['telefono'],
        birthDate: strDateToStrDateView(json['idSocio']['fechaNacimiento']),
        addDate: strYMDHMToStrDMY(json['idSocio']['fechaAlta']),
        updateDate: strYMDHMToStrDMY(json['idSocio']['fechaModificacion']),
        deleteDate: strYMDHMToStrDMY(json['idSocio']['fechaBaja']),
        notes: json['idSocio']['notas']
      )
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': dependentId,
      'nombre': name,
      'apellido': lastname,
      'cedula': document,
      'partnerNovaDaily': partnerNovaDaily,
    };
  }
}
