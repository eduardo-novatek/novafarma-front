import 'package:pf_care_front/model/globals/deserializable.dart';

class SuperAdminReferenceCareObject implements Deserializable <SuperAdminReferenceCareObject> {
  final String? id;
  final String? name;
  final String? surname;
  final int? identificationDocument;
  final bool? isFirst;

  SuperAdminReferenceCareObject.empty():
        id = null, name = null, surname = null, identificationDocument = null, isFirst = null;

  SuperAdminReferenceCareObject({
    this.id,
    this.name,
    this.surname,
    this.identificationDocument,
    this.isFirst = false,
  });

  @override
  SuperAdminReferenceCareObject fromJson(Map<String, dynamic> json) {
    return SuperAdminReferenceCareObject(
      id: json['referenceCaregiverId'],
      name: json['name1'],
      surname: json['surname1'],
      identificationDocument: json['identificationDocument'],
    );
  }

}
