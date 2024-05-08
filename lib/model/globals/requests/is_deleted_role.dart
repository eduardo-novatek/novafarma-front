import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:pf_care_front/model/globals/constants.dart'
    show  socket, timeOutSecondsResponse, uriPatientFindId,
          uriVolunteerPersonFindId;

import '../../enums/role_enum.dart';

//Se deja para evaluacion en funcion evaluateLoggedRole (archivo select_role_screen)
Future<bool> isDeletedRole({
  required RoleEnum role,
  required String entityId}) async {

  late final String uri;
  if (role == RoleEnum.patient) {
    uri = uriPatientFindId;
  } else if (role == RoleEnum.volunteerPerson) {
    uri = uriVolunteerPersonFindId;
  }

  final url = Uri.http(socket,"$uri/$entityId");

  try {
    var response = await http
        .get(url)
        .timeout(const Duration(seconds: timeOutSecondsResponse));

    if (response.statusCode == HttpStatus.ok) {
        final responseData = json.decode(response.body);
        return responseData['deleted'] is bool ? responseData['deleted'] : false;
    } else {
        throw Exception('Error cargando datos');
    }

  } catch (e) {
      if (kDebugMode) print ("Error de conexión: $e");
      throw Exception("Error de conexión");
  }
}