import 'dart:convert';
import 'package:pf_care_front/model/enums/contact_methods_enum.dart';
import 'package:pf_care_front/model/enums/person_gender_enum.dart'
    show nameGenderDBToName;
import 'package:pf_care_front/model/globals/deserializable.dart';
import '../globals/department.dart';
import 'address_object.dart';

class VolunteerPersonObject implements Deserializable <VolunteerPersonObject> {
  final bool? isFirst;
  final bool? match;
  final String? id;
  final String? name;
  final String? surname;
  final String? gender;
  final AddressObject? address;
  final String? telephone;
  final String? mail;
  final DateTime? dateBirth;
  final int? identificationDocument;
  final List<dynamic>? interestZones;
  final String? dayTimeRange;
  final String? training;
  final String? experience;
  final String? reasonToVolunteer;
  final List<dynamic>? contactMethods;
  List<dynamic>? volunteerActivitiesId;
  List<dynamic>? matchRequestPatientsId;
  List<dynamic>? matchPatientsId;
  final DateTime? shippingDate;
  final DateTime? confirmationDate;
  final DateTime? registrationDate;
  final String? countryName;
  final bool? available;
  final bool? validate;
  final bool? deleted;

  VolunteerPersonObject.empty():
        match = null, id = null, name = null, surname = null, gender = null,
        address = null, identificationDocument = null, interestZones = null,
        dayTimeRange = null, isFirst = null, telephone = null, mail = null,
        dateBirth = null, training = null, experience = null,
        reasonToVolunteer = null, contactMethods = null,
        volunteerActivitiesId = null, registrationDate = null, confirmationDate = null,
        shippingDate = null, countryName = null, available = null,
        validate = null, deleted = null;

  VolunteerPersonObject({
    this.match, this.id, this.name, this.surname, this.gender, this.address,
    this.identificationDocument, this.interestZones, this.dayTimeRange,
    this.isFirst = false, this.telephone, this.mail, this.dateBirth,
    this.training, this.experience, this.reasonToVolunteer, this.contactMethods,
    this.volunteerActivitiesId, this.matchRequestPatientsId,
    this.matchPatientsId, this.registrationDate, this.countryName,
    this.confirmationDate, this.shippingDate, this.available, this.validate,
    this.deleted,
  });

  @override
  VolunteerPersonObject fromJson(Map<String, dynamic> json) {
    return VolunteerPersonObject(
      id: json['volunteerPersonId'],
      name: json['name1'],
      surname: json['surname1'],
      gender: nameGenderDBToName(json['gender']),
      address: json['address'] != null
          ? AddressObject.fromJson(json['address'])
          : null,
      identificationDocument: json['identificationDocument'],
      interestZones: _interestZones(json['interestZones'] ?? []),
      dayTimeRange: jsonEncode(json['dayTimeRange']),
      experience: json['experience'],
      reasonToVolunteer: json['reasonToVolunteer'],
      training: json['training'],
      mail: json['mail'],
      telephone: json['telephone'],
      contactMethods: _transformContactMethods(json['contactMethods']),
      dateBirth: DateTime.parse(json['dateBirth']),
      volunteerActivitiesId: json['volunteerActivitiesId'],
      matchRequestPatientsId: json['matchRequestPatientsId'],
      matchPatientsId: json['matchPatientsId'],
      registrationDate: json['registrationDate'] != null
          ? DateTime.parse(json['registrationDate'])
          : null,
      shippingDate: json['shippingDate'] != null
          ? DateTime.parse(json['shippingDate'])
          : null,
      confirmationDate: json['confirmationDate'] != null
          ? DateTime.parse(json['confirmationDate'])
          : null,
      countryName: json['countryName'],
      available: json['available'],
      validate: json['validate'],
      deleted: json['deleted'],
    );
  }

  List<String?>? _transformContactMethods (List<dynamic> contactMethods) {
    return contactMethods.map((e) => contactMethodDBToString(e)).toList();
  }

  List<Department>? _interestZones(List<dynamic> interestZones) {
    return interestZones
        .map((interestZone) => Department.fromJson(interestZone))
        .toList();
  }

}

