import 'package:pf_care_front/model/globals/deserializable.dart';

class SuperAdminVolunteerPersonObject implements Deserializable <SuperAdminVolunteerPersonObject> {
  final String? id;
  final String? name;
  final String? surname;
  final int? identificationDocument;
  final bool? isFirst;

  SuperAdminVolunteerPersonObject.empty():
        id = null, name = null, surname = null, identificationDocument = null,
        isFirst = null;

  SuperAdminVolunteerPersonObject({
    this.id,
    this.name,
    this.surname,
    this.identificationDocument,
    this.isFirst = false,
  });

  @override
  SuperAdminVolunteerPersonObject fromJson(Map<String, dynamic> json) {
    return SuperAdminVolunteerPersonObject(
      id: json['volunteerPersonId'],
      name: json['name1'],
      surname: json['surname1'],
      identificationDocument: json['identificationDocument'],
    );
  }

}
