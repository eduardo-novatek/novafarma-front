import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:pf_care_front/model/enums/role_enum.dart';
import 'package:pf_care_front/model/globals/constants.dart'
    show socket, uriUsersExistIdentificationDocument, timeOutSecondsResponse;

Future<bool> existIdentificationDocument({
  required int identificationDocument,
  required RoleEnum role,
}) async {

  String uri = "";
  if (role == RoleEnum.patient) {
    uri = uriUsersExistIdentificationDocument;
  }

  final url = Uri.http(socket,"$uri/$identificationDocument");

  try {
    var response = await http.get(url)
        .timeout(const Duration(seconds: timeOutSecondsResponse));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error cargando datos');
    }

  } catch (e) {
    if (kDebugMode) print("Error de conexión: $e");
    throw Exception("Error de conexión");
  }

}