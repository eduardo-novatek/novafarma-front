import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:pf_care_front/model/enums/role_enum.dart';
import 'package:pf_care_front/model/globals/constants.dart'
    show socket, timeOutSecondsResponse, uriPatientSetDeletion, uriVolunteerPersonSetDeletion;

Future<bool> setDeletedRole({
  required String id, required bool value, required RoleEnum role}) async {

  String uri = "";
  if (role == RoleEnum.patient) {
    uri = uriPatientSetDeletion;
  } else if (role == RoleEnum.volunteerPerson) {
    uri = uriVolunteerPersonSetDeletion;
  }

  final url = Uri.http(socket,"$uri/$id/$value");

  try {
    var response = await http.put(url)
        .timeout(const Duration(seconds: timeOutSecondsResponse));

    if (response.statusCode == 200) {
        return json.decode(response.body);
    } else if (response.statusCode == 500) {
        return false;
    } else {
        throw Exception('Error en el servidor');
    }

  } catch (e) {
    if (kDebugMode) print("Error de conexión: $e");
    throw Exception("Error de conexión");
  }

}
