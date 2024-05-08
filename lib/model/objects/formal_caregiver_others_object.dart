import 'formal_caregiver_object.dart';

class FormalCaregiverOthersObject extends FormalCaregiverObject {
  String? formalCaregiverId;

  FormalCaregiverOthersObject({
    this.formalCaregiverId,
    required super.name,
    required super.dayTimeRange,
  });

}
