import '../enums/relationship_enum.dart';
import 'carer_object.dart';

class InformalCaregiverObject extends CarerObject {
  String? telephone;
  RelationshipEnum relationship;

  InformalCaregiverObject({
    this.telephone,
    required this.relationship,
    required super.name,
    required super.dayTimeRange
  });
}
