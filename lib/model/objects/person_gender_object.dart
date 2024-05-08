import 'package:pf_care_front/model/enums/person_gender_enum.dart';

class PersonGenderObject {
  final PersonGenderEnum? personGenderEnum;
  final String label;
  final bool isFirst;

  PersonGenderObject({
    this.isFirst = false,
    this.personGenderEnum,
    required this.label
  });

  @override
  String toString() {
    return label;
  }
}