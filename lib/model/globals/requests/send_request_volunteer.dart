import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:pf_care_front/model/enums/role_enum.dart';
import 'package:pf_care_front/model/globals/constants.dart'
    show socket, timeOutSecondsResponse, uriPatientSendRequestToVolunteerPerson;

Future<bool> sendRequest({
  required String patientId,
  required String volunteerPersonId,
    required RoleEnum role}) async {

    String uri = uriPatientSendRequestToVolunteerPerson;
    if (role == RoleEnum.formalCare) {
      //uri = ...
    }

    final url = Uri.http(socket,"$uri/$patientId/$volunteerPersonId");

    try {
      var response = await http.get(url)
          .timeout(const Duration(seconds: timeOutSecondsResponse));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 409) {
          throw Exception('La solicitud de contacto ya había sido enviada');
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
