import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:pf_care_front/model/globals/constants.dart'
    show socket, uriUsersLogin, timeOutSecondsResponse;

Future<(Map<String, dynamic>?, String?)> doLogin ({
  required int identificationDocument,
  required String pass}) async {

  Map<String, dynamic> user = {
    'identificationDocument': identificationDocument,
    'pass': pass,
  };

  final url = Uri.http(socket, uriUsersLogin);

  try {
    var response = await http.post(
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        url,
        body: json.encode(user)
    ).timeout(const Duration(seconds: timeOutSecondsResponse));

    if (response.statusCode == HttpStatus.ok) {
      return (json.decode(response.body) as Map<String, dynamic>, null);
    } else {
      if (response.statusCode == HttpStatus.unauthorized) {
        return (null, "Usuario o contraseña incorrecta");
      } else { // Internal Server Error (500)
        return (null, "Error en el servidor");
      }
    }

  } catch (e) {
      if (kDebugMode) print("Error en el servidor: $e");
      throw Exception("Error de conexión");
  }
}
