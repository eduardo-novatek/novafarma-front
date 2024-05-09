import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:novafarma_front/model/enums/role_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart'
    show socket, uriUsersAdd, timeOutSecondsResponse;

Future<(bool, String?)> addUser({
    required String name,
    required String surname,
    required int identificationDocument,
    required List<RoleEnum> roles,
    required String country,
    required String department,
    required String city,
    required String neighborhood,
    required String pass}) async {

  List<Map<String, String>> rolesList = roles
      .map((e) => {'rol': nameRole(roleEnum: e, forDatabases: true)})
      .toList();

    Map<String, dynamic> newUser = {
      'identificationDocument': identificationDocument,
      'pass': pass,
      'name': name,
      'surname': surname,
      'roles': rolesList,
      'residenceZone': {
        'neighborhoodName': neighborhood,
        'cityName': city,
        'departmentName': department,
        'countryName': country
      }
    };

    final url = Uri.http(socket, uriUsersAdd);

    try {
      var response = await http.post(
          headers: {'Content-Type': 'application/json'},
          url,
          body: json.encode(newUser)
      ).timeout(const Duration(seconds: timeOutSecondsResponse));

      if (response.statusCode == HttpStatus.ok) {
        //final String data = json.decode(response.body);
        return (true, null);
      } else {
        //conflict
        if (response.statusCode == HttpStatus.conflict) {
          return (false, "El usuario ya existe");
        } else { // Internal Server Error (500)
          return (false, "Error en el servidor");
        }
      }

    } catch (e) {
      if (kDebugMode) print("Error de conexion: $e");
      throw Exception("Error de conexion");

    }
}
