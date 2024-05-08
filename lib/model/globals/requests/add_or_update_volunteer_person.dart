import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:pf_care_front/model/globals/constants.dart'
    show socket, uriVolunteerPersonAdd, timeOutSecondsResponse,
          uriVolunteerPersonUpdate;
import 'package:pf_care_front/model/globals/publics.dart';

import '../../enums/action_enum.dart';
import '../../enums/person_gender_enum.dart';
import '../../enums/role_enum.dart';
import '../interest_zones_to_json.dart';
import '../tools/geolocation.dart';
import '../tools/to_date_bd.dart';
import '../user_logged_obtain_entity_id_by_role.dart';

double latitude = 0;
double longitude = 0;

Future<(bool, String)> addOrUpdateVolunteerPerson({
  required ActionEnum action,
  required PersonGenderEnum gender,
  required String telephone,
  required String mail,
  required String dateBirth,
  required String street,
  required int portNumber,
  required String betweenStreet1,
  required String betweenStreet2,
  required List<String?> contactMethods,
  required bool available,
  required List<Map<String, dynamic>> interestZones,
  required List<Map<String, dynamic>> dayTimeRange,
  required List<String> activitiesId,
  required String training,
  required String experience,
  required String reasonToVolunteer,

  }) async {
      final locationResult = await _updatePosition();

      Map<String, dynamic> newMap = mapCreate(
          action: action,
          gender: gender,
          telephone: telephone,
          mail: mail,
          dateBirth: dateBirth,
          street: street,
          portNumber: portNumber,
          betweenStreet1: betweenStreet1,
          betweenStreet2: betweenStreet2,
          locationResult:  locationResult,
          contactMethods: contactMethods,
          available: available,
          interestZones: interestZones,
          dayTimeRange: dayTimeRange,
          activitiesId: activitiesId,
          training: training,
          experience: experience,
          reasonToVolunteer: reasonToVolunteer,
      );

      final url = Uri.http(socket, action == ActionEnum.add
          ? uriVolunteerPersonAdd
          : uriVolunteerPersonUpdate
      );

      try {
        http.Response response;

        if (action == ActionEnum.add) {
           response = await http.post(
            headers: {'Content-Type': 'application/json'},
            url,
            body: json.encode(newMap),
          ).timeout(const Duration(seconds: timeOutSecondsResponse));

        } else {
          response = await http.put(
            headers: {'Content-Type': 'application/json'},
            url,
            body: json.encode(newMap),
          ).timeout(const Duration(seconds: timeOutSecondsResponse));
        }

        if (response.statusCode == HttpStatus.ok) {
          return (true, response.body); // Devuelve el id
        } else {
          return (false, "Error en el servidor");
        }

      } catch (e) {
        if (kDebugMode) print("Error de conexión: $e");
        throw Exception("Error de conexión");
      }

}

Map<String, dynamic> mapCreate({
  required ActionEnum action,
  required PersonGenderEnum gender,
  required String telephone,
  required String mail,
  required String dateBirth,
  required String street,
  required int portNumber,
  required String betweenStreet1,
  required String betweenStreet2,
  required (double, double)? locationResult,
  required List<String?> contactMethods,
  required bool available,
  required List<Map<String, dynamic>> interestZones,
  required List<Map<String, dynamic>> dayTimeRange,
  required List<String> activitiesId,
  required String training,
  required String experience,
  required String reasonToVolunteer}) {

    return
    {
        if (action == ActionEnum.modify) 'volunteerPersonId':
            userLoggedObtainEntityIdByRole(
              nameRole(roleEnum: RoleEnum.volunteerPerson, forDatabases: true))!,
        'identificationDocument': userLogged["identificationDocument"],
        'userId': userLogged['userId'],
        'name1': userLogged["name"],
        'surname1': userLogged["surname"],
        'countryName': userLogged['residenceZone']['countryName'],
        'gender': nameGender(genderEnum: gender, forDatabases: true),
        'telephone': (telephone.isNotEmpty ? telephone : null),
        'mail': (mail.isNotEmpty ? mail : null),
        'dateBirth': toDateBD(dateBirth),
        'address': {
          'street': street,
          'portNumber': portNumber,
          'betweenStreet1': betweenStreet1,
          'betweenStreet2': betweenStreet2,
          if (locationResult != null) 'lat': locationResult.$1,
          if (locationResult != null) 'lon': locationResult.$2,
        },
        'contactMethods': contactMethods,
        'available': available,
        'interestZones': interestZonesTransform(interestZones),
        'dayTimeRange': dayTimeRange,
        'volunteerActivitiesId': activitiesId,
        'training': training,
        'experience': experience,
        'reasonToVolunteer': reasonToVolunteer
    };
}

Future<(double, double)?> _updatePosition() async {
  return await obtainLatitudeLongitude().then((result, ) {
    if (result != null) {
      if (kDebugMode) print("Latitud: ${result.$1}, Longitud: ${result.$2}");
      return (result.$1, result.$2); //(latitud, longitud)

    } else {
      if (kDebugMode) {
        print('Los servicios de ubicación no están habilitados');
      }
      return null;
    }
  });
}
