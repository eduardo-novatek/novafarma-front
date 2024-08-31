import 'dart:convert';
import 'dart:core';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:novafarma_front/model/DTOs/customer_dto2.dart';
import 'package:novafarma_front/model/DTOs/nursing_report_dto.dart';
import 'package:novafarma_front/model/globals/constants.dart'
    show socket, timeOutSecondsResponse;
import 'package:novafarma_front/model/objects/error_object.dart';
import 'package:novafarma_front/model/objects/page_object_map.dart';

///Devuelve una lista de objetos de la base de datos, obtenidos por paginación.
///Envía solo solicitudes get.
Future<PageObjectMap> fetchNursingReportPageable({
  required String uri,
}) async {
  Uri url;
  Response response;
  bool generalException = true;

  try {
    url = Uri.http(socket, uri);
    response = await http
        .get(url)
        .timeout(const Duration(seconds: timeOutSecondsResponse));

    if (response.statusCode == 200) {
      try {
        if (response.body.isEmpty) return PageObjectMap.empty();
        dynamic decodedData = json.decode(response.body);

        // Inicializa el mapa de contenido.
        Map<CustomerDTO2, List<NursingReportDTO>> content = {};

        // Recorre la lista de 'content'.
        for (var entry in decodedData['content']) {
          // Las claves son strings que contienen la información de CustomerDTO2.
          String customerKey = entry.keys.first; // "CustomerDTO1(document=56848028, name=JOSE OLIVARES)"
          List<dynamic> reports = entry.values.first; // Lista de NursingReportDTO en formato JSON.

          // Extrae el 'document' y 'name' del string de la clave.
          //RegExp regExp = RegExp(r"document=(\d+), name=(.+)");
          RegExp regExp = RegExp(r"document=(\d+), name=(.+)\)$"); // Omite el ')' final
          RegExpMatch? match = regExp.firstMatch(customerKey);

          int? document = match != null ? int.parse(match.group(1)!) : null;
          String? name = match?.group(2);

          CustomerDTO2 customer = CustomerDTO2(
            document: document,
            name: name,
          );

          // Mapea los elementos del informe de enfermería a NursingReportDTO.
          List<NursingReportDTO> nursingReports = reports
              .map((reportJson) => NursingReportDTO().fromJson(reportJson))
              .toList();

          // Agrega la entrada al mapa de contenido.
          content[customer] = nursingReports;
        }

        return Future.value(
          PageObjectMap(
            content: content,
            pageNumber: decodedData['number'],
            pageSize: decodedData['size'],
            totalPages: decodedData['totalPages'],
            totalElements: decodedData['totalElements'],
            first: decodedData['first'],
            last: decodedData['last'],
          ),
        );
      } catch (e) {
        generalException = false;
        if (kDebugMode) print("Error al decodificar la respuesta JSON $e");
        throw ErrorObject(
          statusCode: 0,
          message: 'Error al decodificar la respuesta JSON $e',
        );
      }
    } else {
      generalException = false;
      throw ErrorObject(
        statusCode: response.statusCode,
        message: response.body.isNotEmpty
            ? jsonDecode(response.body)['message']
            : null,
      );
    }
  } catch (e) {
    if (generalException) {
      rethrow;
    }
    return Future.error(e);
  }
}

/*Future<PageObjectMap> fetchNursingReportPageable ({ //})<T extends Deserializable<T>>({
  required String uri,
  //required T classObject,
}) async {

  Uri url;
  Response response;
  bool generalException = true;

  try {
    url = Uri.http(socket, uri);
    response = await http.get(url)
        .timeout(const Duration(seconds: timeOutSecondsResponse));

    if (response.statusCode == 200) {
      try {
        if (response.body.isEmpty) return PageObjectMap.empty();
        dynamic decodedData = json.decode(response.body);
        Map<CustomerDTO2, List<NursingReportDTO>> content =
          (decodedData['content'] as Map<CustomerDTO2, List<NursingReportDTO>>)
          .map((key, value) {

          });

        //List<T> content = (decodedData['content'] as List)
        //    .map((item) => classObject.fromJson(item)).toList();
        return Future.value(
              PageObjectMap(
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

}*/