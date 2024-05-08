import 'package:pf_care_front/model/globals/deserializable.dart';

class VolunteerContactedObject implements Deserializable<VolunteerContactedObject> {
  String? volunteerPersonId;
  bool? match;

  VolunteerContactedObject ({
    required this.volunteerPersonId,
    required this.match
  });

  VolunteerContactedObject.empty(): volunteerPersonId = null, match = null;

  @override
  fromJson(Map<String, dynamic> json) {
    return VolunteerContactedObject(
        volunteerPersonId: json["volunteerPersonId"],
        match: json["match"],
    );
  }
}