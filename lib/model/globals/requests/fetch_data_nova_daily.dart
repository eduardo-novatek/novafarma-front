import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:novafarma_front/model/globals/constants.dart'
    show timeOutSecondsResponse;
import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../enums/request_type_enum.dart';

/// value: valor a buscar. body: está por si se implementa un post
Future<List<Object>> fetchDataNovaDaily <T extends Deserializable<T>>({
  required Uri uri,
  required T classObject,
  RequestTypeEnum? requestType = RequestTypeEnum.get,
  Object? body,
}) async {

  http.Response response;
  bool generalException = true;

  try {
    if (requestType == RequestTypeEnum.post) {
        response = await http.post(
            uri,
            body: json.encode(body),
            headers:{
              "Content-Type": "application/json; charset=UTF-8",
            }
        ).timeout(const Duration(seconds: timeOutSecondsResponse));

    } else if (requestType == RequestTypeEnum.put) {
      response = await http.put(
          uri,
          body: json.encode(body),
          headers: {"Content-Type": "application/json; charset=UTF-8",}
      ).timeout(const Duration(seconds: timeOutSecondsResponse));

    } else {
      response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Accept": "application/json"
        }
      ).timeout(const Duration(seconds: timeOutSecondsResponse));
    }

    if (response.statusCode == 200) {
      try {
        if (response.body.isEmpty) return [];

        // Intenta decodificar el Json
        try {
          //Utiliza explícitamente un decodificador UTF-8 para manejar la codificación.
          //La línea que usa utf8.decode podría ser ligeramente más segura si
          // existe la posibilidad de que la respuesta no esté codificada en UTF-8,
          // pero en la mayoría de los casos, ambos enfoques son intercambiables.
          //dynamic decodedData = json.decode(utf8.decode(response.bodyBytes));
          dynamic decodedData = json.decode(response.body);

          if (decodedData is List) {
            return decodedData.map((item) => classObject.fromJson(item))
                .toList();
          } else if (decodedData is Map<String, dynamic>) {
            return [classObject.fromJson(decodedData)].toList();
          } else if (decodedData is bool) {
            return [decodedData].toList();
          } else if (decodedData is int) {
            return [decodedData].toList();
          } else {
            String err = 'Tipo de datos desconocido';
            if (decodedData == null) err = 'No se obtuvo respuesta de NovaDaily';
            if (kDebugMode) print(err);
            throw ErrorObject(
              statusCode: 0,
              message: err
            );
          }
        } catch (e) {
          if (e is ErrorObject) {
            return Future.error(e);
          } else {
            //No pudo decodificar el Json, asume que es un String
            return [response.body];
          }

        }
      } catch (e) {
        generalException = false;
        if (kDebugMode) print("Error al decodificar la respuesta JSON $e");
        throw ErrorObject(
          statusCode: 0,
          message: 'Error al decodificar la respuesta JSON $e'
        );
      }

    } else {
      generalException = false;
      throw ErrorObject(
        statusCode: response.statusCode,
        message: response.body.isNotEmpty
            ? jsonDecode(response.body)['message']
            : null
      );

    }
  } catch (e) {
    if (generalException) {
      rethrow;
    }
    return Future.error(e);
  }

}