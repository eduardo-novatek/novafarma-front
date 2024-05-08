import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:pf_care_front/model/enums/role_enum.dart';
import 'package:pf_care_front/model/globals/constants.dart'
    show  socket, uriFormalCareExistTelephone, uriVolunteerPersonExistTelephone,
          uriPatientExistTelephone, timeOutSecondsResponse;
import 'package:pf_care_front/model/globals/publics.dart';

Future<bool> existTelephone({required String telephone, required RoleEnum role}) async {

    String uri = "";
    String finalUri = "/${userLogged['residenceZone']['countryName']}";
    if (role == RoleEnum.patient) {
        uri = uriPatientExistTelephone;
    } else if (role == RoleEnum.volunteerPerson) {
        uri = uriVolunteerPersonExistTelephone;
    } else if (role == RoleEnum.formalCare) {
        uri = uriFormalCareExistTelephone;
    }

    final url = Uri.http(socket,"$uri/$telephone$finalUri");

    try {
      var response = await http.get(url)
          .timeout(const Duration(seconds: timeOutSecondsResponse));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 500) {
        return false;
      } else {
        throw Exception('Error cargando datos');
      }

    } catch (e) {
      if (kDebugMode) print("Error de conexión: $e");
      throw Exception("Error de conexión");
    }

}
