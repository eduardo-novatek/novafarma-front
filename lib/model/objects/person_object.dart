import '../enums/person_gender_enum.dart';
import 'address_object.dart';

class PersonObject {
  String? name1;
  String? surname1;
  PersonGenderEnum? gender;
  AddressObject? address;
  String? telephone;
  String? mail;
  int? identificationDocument;
  DateTime? dateBirth;

  PersonObject();
  
  PersonObject.complete(
      {required this.name1,
      required this.surname1,
      required this.gender,
      required this.address,
      required this.telephone,
      required this.mail,
      required this.identificationDocument,
      required this.dateBirth});
}