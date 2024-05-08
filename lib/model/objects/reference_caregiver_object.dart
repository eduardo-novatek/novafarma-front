import 'package:pf_care_front/model/objects/person_object.dart';
import '../enums/relationship_enum.dart';
import 'day_time_range_object.dart';

class ReferenceCaregiverObject extends PersonObject {
  RelationshipEnum? relationship;
  List<DayTimeRangeObject>? dayTimeRange;

  ReferenceCaregiverObject();

  ReferenceCaregiverObject.complete({
      required this.relationship,
      required this.dayTimeRange //Dias y rangos horarios semanales para el cuidado
  });

}