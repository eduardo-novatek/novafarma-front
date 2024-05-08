import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:pf_care_front/model/globals/constants.dart'
    show  socket, uriPatientValidatedAndNotDeleted, timeOutSecondsResponse,
          uriReferenceCareHasPatientAssigned, uriFormalCareValidatedAndNotDeleted,
          uriVolunteerPersonValidatedAndNotDeleted;

import '../../enums/role_enum.dart';

//Se deja para evaluacion en funcion evaluateLoggedRole (archivo select_role_screen)
Future<bool> isValidatedRole({
  required RoleEnum role,
  required String entityId}) async {

  late final String uri;
  if (role == RoleEnum.patient) {
    uri = uriPatientValidatedAndNotDeleted;
  } else if (role == RoleEnum.referenceCare) {
    uri = uriReferenceCareHasPatientAssigned;
  } else if (role == RoleEnum.formalCare) {
    uri = uriFormalCareValidatedAndNotDeleted;
  } else if (role == RoleEnum.volunteerPerson) {
    uri = uriVolunteerPersonValidatedAndNotDeleted;
  }

  final url = Uri.http(socket,"$uri/$entityId");

  try {
    var response = await http
        .get(url)
        .timeout(const Duration(seconds: timeOutSecondsResponse));

    if (response.statusCode == HttpStatus.ok) {
      final responseData = json.decode(response.body);
      return responseData is bool ? responseData : false;
    } else {
      throw Exception('Error cargando datos');
    }

  } catch (e) {
    if (kDebugMode) print ("Error de conexión: $e");
    throw Exception("Error de conexión");
  }
}