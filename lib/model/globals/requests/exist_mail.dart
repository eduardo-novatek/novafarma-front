import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:pf_care_front/model/enums/role_enum.dart';
import 'package:pf_care_front/model/globals/constants.dart'
    show  socket, uriPatientExistMail, timeOutSecondsResponse,
          uriReferenceCareExistMail, uriFormalCareExistMail,
          uriVolunteerPersonExistMail;

Future<bool> existMail({required String mail, required RoleEnum role}) async {

    String uri = "";
    if (role == RoleEnum.patient) {
      uri = uriPatientExistMail;
    } else if (role == RoleEnum.volunteerPerson) {
      uri = uriVolunteerPersonExistMail;
    } else if (role == RoleEnum.referenceCare) {
      uri = uriReferenceCareExistMail;
    } else if (role == RoleEnum.formalCare) {
      uri = uriFormalCareExistMail;
    }

    final url = Uri.http(socket,"$uri/$mail");

    try {
      var response = await http.get(url)
          .timeout(const Duration(seconds: timeOutSecondsResponse));
      if (response.statusCode == HttpStatus.ok) {
          return json.decode(response.body);
      } else {
          throw Exception('Error cargando datos');
      }

    } catch (e) {
      if (kDebugMode) print("Error de conexión: $e");
      throw Exception("Error de conexión");
    }

}
