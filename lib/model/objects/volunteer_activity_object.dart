import 'package:pf_care_front/model/globals/deserializable.dart';

class VolunteerActivityObject implements Deserializable <VolunteerActivityObject> {
  final String name;
  final String? id;
  final bool? isFirst;

  VolunteerActivityObject.empty(): id = null, name = "", isFirst = null;

  VolunteerActivityObject({
    required this.name,
    this.isFirst = false,
    this.id
  });

  @override
  VolunteerActivityObject fromJson(Map<String, dynamic> json) {
    return VolunteerActivityObject(
      id: json['volunteerActivityId'],
      name: json['name'],
    );
  }

  @override
  String toString() {
    return name;
  }
}
