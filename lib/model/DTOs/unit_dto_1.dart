import 'package:novafarma_front/model/globals/deserializable.dart';

class UnitDTO1 extends Deserializable<UnitDTO1> {
  int? unitId;

  UnitDTO1.empty():
    unitId = null
  ;

    UnitDTO1({this.unitId,});

    @override
    UnitDTO1 fromJson(Map<String, dynamic> json) {
    return UnitDTO1(
      unitId: json['unitId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'unitId': unitId,
    };
  }

 /* @override
  String toString() {
    return name;
  }*/

}