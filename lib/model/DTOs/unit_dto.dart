import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

import 'customer_dto.dart';
import 'medicine_dto.dart';

class UnitDTO extends Deserializable<UnitDTO> {
  int? unitId;
  String? name;

  UnitDTO.empty():
    unitId = null,
    name = null
  ;

    UnitDTO({this.unitId,this.name,});

    @override
    UnitDTO fromJson(Map<String, dynamic> json) {
    return UnitDTO(
      unitId: json['unitId'],
      name: json['name'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'unitId': unitId,
      'name': name,
    };
  }

 /* @override
  String toString() {
    return name;
  }*/

}