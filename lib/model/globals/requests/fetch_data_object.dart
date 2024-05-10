import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:novafarma_front/model/globals/constants.dart'
    show socket, timeOutSecondsResponse;
import 'package:novafarma_front/model/globals/deserializable.dart';

import '../../enums/request_type_enum.dart';

///Devuelve una lista de objetos de la base de datos.
Future<List<Object>> fetchDataObject <T extends Deserializable<T>>({
  required String uri,  //tomada de las constantes
  required T classObject,
  RequestTypeEnum? requestType = RequestTypeEnum.get,
  Object? body,
}) async {

  Uri url;
  Response response;

  try {
    url = Uri.http(socket, uri);

    if (requestType == RequestTypeEnum.post) {
        response = await http.post(
            url,
            body: json.encode(body),
            headers:
            {
              "Content-Type": "application/json; charset=UTF-8",
            }
        ).timeout(const Duration(seconds: timeOutSecondsResponse));

    } else if (requestType == RequestTypeEnum.put) {
      response = await http.put(
          url,
          body: json.encode(body),
          headers: {"Content-Type": "application/json; charset=UTF-8",}
      ).timeout(const Duration(seconds: timeOutSecondsResponse));

    } else {
      response = await http.get(url)
          .timeout(const Duration(seconds: timeOutSecondsResponse));
    }

    if (response.statusCode == 200) {
      try {
        //Asume que el cuerpo de la respuesta está codificado en UTF-8 por defecto
        //dynamic decodedData = json.decode(response.body);

        //Utiliza explícitamente un decodificador UTF-8 para manejar la codificación.
        //La línea que usa utf8.decode podría ser ligeramente más segura si
        // existe la posibilidad de que la respuesta no esté codificada en UTF-8,
        // pero en la mayoría de los casos, ambos enfoques son intercambiables.
        //dynamic decodedData = json.decode(utf8.decode(response.bodyBytes));
        dynamic decodedData = json.decode(response.body);

        if (decodedData is List) {
          return decodedData.map((item) => classObject.fromJson(item)).toList();
        } else if (decodedData is Map<String, dynamic>) {
          return [classObject.fromJson(decodedData)].toList();
        } else if (decodedData is bool) {
          return [decodedData].toList();
        } else {
          if (kDebugMode) print("Tipo de datos desconocido");
          throw Exception('Tipo de datos desconocido');
        }
      } catch (e) {
        if (kDebugMode) print("Error al decodificar la respuesta JSON $e");
        throw Exception('Error al decodificando datos');
      }
    } else {
      if (kDebugMode) print("Error cargando datos: error ${response.statusCode}. ${response.body}");
      throw Exception('Error cargando datos: ');
    }
  } catch (e) {
    if (kDebugMode) print("Error de conexión: $e");
    throw Exception("Error de conexión");
  }

}