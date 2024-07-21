import 'package:novafarma_front/model/DTOs/partner_nova_daily_dto.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

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
      document: json['cedula'],
      partnerNovaDaily: partnerNovaDaily?.fromJson(json['idSocio'])
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
