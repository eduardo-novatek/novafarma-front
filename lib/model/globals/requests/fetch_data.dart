import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:pf_care_front/model/globals/constants.dart'
    show socket, timeOutSecondsResponse;

Future<List<String>> fetchData ({
  required String uri,  //tomada de las constantes. Ej: uriHealthProviderFindByCity
  String? key,  //key del json a obtener. Ej: "name". Si se omite, se devuelve el objeto directamente
  String? cityName,
  String? departmentName,
  String? countryName,
}) async {

  String finalUri = uri;
  if (cityName != null) finalUri = "$finalUri/$cityName";
  if (departmentName != null) finalUri = "$finalUri/$departmentName";
  if (countryName != null) finalUri = "$finalUri/$countryName";

  final url = Uri.http(socket, finalUri);

  try {
    var response = await http.get(url)
        .timeout(const Duration(seconds: timeOutSecondsResponse));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (key != null) return data.map((e) => e[key].toString()).toList();
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception('Error cargando datos');
    }

  } catch (e) {
    if (kDebugMode) print("Error de conexión: $e");
    throw Exception("Error de conexión");
  }
}