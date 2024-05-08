import '../enums/person_gender_enum.dart' show nameGenderDBToName;
import '../globals/deserializable.dart';
import 'address_object.dart';

class PatientObject implements Deserializable <PatientObject> {
  final bool? isFirst;
  final String? patientId;
  final String? userId;
  final String? name;
  final String? surname;
  final String? gender;
  final AddressObject? address;
  final String? telephone;
  final String? mail;
  final DateTime? dateBirth;
  final int? identificationDocument;
  final String? referenceCaregiverId;
  final List<dynamic>? formalCaregiversId;
  final List<dynamic>? volunteerPeople;
    final String? healthProviderId;
  final String? emergencyServiceId;
  final String? residentialId;
  //Notar que 'zone' es un mapa. También se podría haberlo manejado como
  //se hizo con address, creando un nuevo tipo (ZoneObject) con opcion de
  //deserealizar mediante un fromJson.
  final Map<String, dynamic>? zone;
  final DateTime? registrationDate;
  final bool? validate;
  final bool? deleted;

  PatientObject.empty()
      : isFirst = null, patientId = null, userId = null, name = null,
        surname = null, gender = null, address = null, telephone = null,
        mail = null, dateBirth = null, identificationDocument = null,
        referenceCaregiverId = null, formalCaregiversId = null,
        volunteerPeople = null, healthProviderId = null,
        emergencyServiceId = null, residentialId = null, zone = null,
        registrationDate = null, validate = null, deleted = null;


  PatientObject({
    this.isFirst, this.patientId, this.userId, this.name, this.surname,
    this.gender, this.address, this.telephone, this.mail, this.dateBirth,
    this.identificationDocument, this.referenceCaregiverId,
    this.formalCaregiversId, this.volunteerPeople, this.healthProviderId,
    this.emergencyServiceId, this.residentialId, this.zone,
    this.registrationDate,this.validate, this.deleted,
  });

  @override
  PatientObject fromJson(Map<String, dynamic> json) {
    return PatientObject (
      patientId: json['patientId'],
      userId: json['userId'],
      name: json['name1'],
      surname: json['surname1'],
      gender: nameGenderDBToName(json['gender']),
      address: json['address'] != null
          ? AddressObject.fromJson(json['address'])
          : null,
      telephone: json['telephone'],
      mail: json['mail'],
      dateBirth: DateTime.parse(json['dateBirth']),
      identificationDocument: json['identificationDocument'],
      referenceCaregiverId: json['referenceCaregiverId'],
      formalCaregiversId: json['formalCaregiversId'],
      volunteerPeople: json['volunteerPeople'],
      healthProviderId: json['healthProviderId'],
      emergencyServiceId: json['emergencyServiceId'],
      residentialId: json['residentialId'],
      zone: json['zone'],
      registrationDate: DateTime.parse(json['registrationDate']),
      validate: json['validate'],
      deleted: json['deleted'],
    );
  }

}
