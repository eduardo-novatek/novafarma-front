import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart' show socket, timeOutSecondsResponse, uriUserNameExist;

Future<bool> userNameExist({required String userName}) async {
  String uri = uriUserNameExist;
  final url = Uri.http(socket,"$uri/$userName");
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
