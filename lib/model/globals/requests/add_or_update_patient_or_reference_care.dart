import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:pf_care_front/model/enums/action_enum.dart';
import 'package:pf_care_front/model/globals/constants.dart'
    show socket, uriPatientAdd, uriReferenceCareAdd, timeOutSecondsResponse,
         uriPatientUpdate, uriReferenceCareUpdate;
import 'package:pf_care_front/model/globals/publics.dart';
import 'package:pf_care_front/model/globals/tools/geolocation.dart';
import 'package:pf_care_front/model/globals/user_logged_obtain_entity_id_by_role.dart';

import '../../enums/person_gender_enum.dart';
import '../../enums/role_enum.dart';
import '../tools/to_date_bd.dart';

double latitude = 0;
double longitude = 0;

Future<(bool, String)> addOrUpdatePatientOrReferenceCare({
  required ActionEnum action,
  required RoleEnum role,
  required PersonGenderEnum gender,
  required String telephone,
  required String mail,
  required String dateBirth,
  required String street,
  required int portNumber,
  required String betweenStreet1,
  required String betweenStreet2,
  String? id,
  String? healthProviderId,
  String? emergencyServiceId,
  String? residentialId,
  }) async {

      final locationResult = await _updatePosition();
      /*if (locationResult == null) {
        return (false, "No se pudo obtener la ubicación del dispositivo");
      }*/
      Map<String, dynamic> newMap = mapCreate(action, role, gender, telephone,
          mail, dateBirth, healthProviderId, emergencyServiceId, residentialId,
          street, portNumber, betweenStreet1, betweenStreet2, locationResult);

      final url = Uri.http(socket, role == RoleEnum.patient
          ? action == ActionEnum.add ? uriPatientAdd : uriPatientUpdate
          : action == ActionEnum.add ? uriReferenceCareAdd : uriReferenceCareUpdate
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
            return (true, response.body); // Devuelve el id del paciente
        } else {
            return (false, "Error en el servidor");
        }

      } catch (e) {
        if (kDebugMode) print("Error de conexión: $e");
        throw Exception("Error de conexión");
      }


}

Map<String, dynamic> mapCreate(
    ActionEnum action,
    RoleEnum role,
    PersonGenderEnum gender,
    String telephone,
    String mail,
    String dateBirth,
    String? healthProviderId,
    String? emergencyServiceId,
    String? residentialId,
    String street,
    int portNumber,
    String betweenStreet1,
    String betweenStreet2,
    (double, double)? locationResult,
    ) {
  return role == RoleEnum.patient
      ? {
          if (action == ActionEnum.modify) 'patientId': userLoggedObtainEntityIdByRole(
            nameRole(roleEnum: role, forDatabases: true),
          )!,
          'identificationDocument': userLogged["identificationDocument"],
          'userId': userLogged['userId'],
          'name1': userLogged["name"],
          'surname1': userLogged["surname"],
          'gender': nameGender(genderEnum: gender, forDatabases: true),
          'telephone': telephone.isNotEmpty ? telephone : null,
          'mail': mail.isNotEmpty ? mail : null,
          'dateBirth': toDateBD(dateBirth),
          'healthProviderId': healthProviderId,
          'emergencyServiceId': emergencyServiceId,
          'residentialId': residentialId,
          'address': {
            'street': street,
            'portNumber': portNumber,
            'betweenStreet1': betweenStreet1,
            'betweenStreet2': betweenStreet2,
            if (locationResult != null) 'lat': locationResult.$1,
            if (locationResult != null) 'lon': locationResult.$2,
          },
          'zone': {
            'neighborhoodName': userLogged['residenceZone']['neighborhoodName'],
            'cityName': userLogged['residenceZone']['cityName'],
            'departmentName': userLogged['residenceZone']['departmentName'],
            'countryName': userLogged['residenceZone']['countryName'],
          },
      }
      : {
          if (action == ActionEnum.modify) 'referenceCaregiverId': userLoggedObtainEntityIdByRole(
            nameRole(roleEnum: role, forDatabases: true),
          ),
          'identificationDocument': userLogged["identificationDocument"],
          'userId': userLogged['userId'],
          'name1': userLogged["name"],
          'surname1': userLogged["surname"],
          'gender': nameGender(genderEnum: gender, forDatabases: true),
          'telephone': telephone.isNotEmpty ? telephone : null,
          'mail': mail.isNotEmpty ? mail : null,
          'dateBirth': toDateBD(dateBirth),
          'patients': [],
          'address': {
            'street': street,
            'portNumber': portNumber,
            'betweenStreet1': betweenStreet1,
            'betweenStreet2': betweenStreet2,
            'lat': locationResult?.$1,
            'lon': locationResult?.$2,
          },
          'zone': {
            'neighborhoodName': userLogged['residenceZone']['neighborhoodName'],
            'cityName': userLogged['residenceZone']['cityName'],
            'departmentName': userLogged['residenceZone']['departmentName'],
            'countryName': userLogged['residenceZone']['countryName'],
          },
      };
}

Future<(double, double)?> _updatePosition() async {
  return await obtainLatitudeLongitude().then((result) {
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