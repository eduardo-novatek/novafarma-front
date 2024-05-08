import '../enums/formal_caregiver_enum.dart';
import 'carer_object.dart';

class FormalCaregiverObject extends CarerObject{
  FormalCareEnum? type;
  int? priceHour;

  FormalCaregiverObject({
    this.type,
    this.priceHour,
    required super.name,
    required super.dayTimeRange
  });
}
