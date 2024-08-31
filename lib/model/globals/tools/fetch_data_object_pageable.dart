import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:novafarma_front/model/globals/constants.dart'
    show socket, timeOutSecondsResponse;
import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/objects/error_object.dart';
import 'package:novafarma_front/model/objects/page_object.dart';

///Devuelve una lista de objetos de la base de datos, obtenidos por paginación.
///Envía solo solicitudes get.
Future<PageObject> fetchDataObjectPageable <T extends Deserializable<T>>({
  required dynamic uri,
  required T classObject,
  //true: la url ya viene armada para que el backend consuma la consulta con RequestParams
  //con lo cual se ignora el armado de la url
  bool isRequestParam = false
}) async {

  Uri url;
  Response response;
  bool generalException = true;

  try {
    if (! isRequestParam) {
      url = Uri.http(socket, uri as String);
    } else {
      url = uri as Uri;
    }

    response = await http.get(url)
        .timeout(const Duration(seconds: timeOutSecondsResponse));

    if (response.statusCode == 200) {
      try {
        if (response.body.isEmpty) return PageObject.empty();
        dynamic decodedData = json.decode(response.body);
        List<T> content = (decodedData['content'] as List)
            .map((item) => classObject.fromJson(item)).toList();
        return Future.value(
              PageObject(
                content: content,
                pageNumber: decodedData['number'],
                pageSize: decodedData['size'],
                totalPages: decodedData['totalPages'],
                totalElements: decodedData['totalElements'],
                first: decodedData['first'],
                last: decodedData['last']
              )
          );
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