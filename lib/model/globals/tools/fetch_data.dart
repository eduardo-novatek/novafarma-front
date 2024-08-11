import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import '../../objects/error_object.dart';
import '../constants.dart' show socket, timeOutSecondsResponse, uriPresentationFindNameOnly;

///Devuelve una List<T> del endpoint especificado (solo get). El tipo de datos
///debe ser un primitivo (para objetos usar fetchDataObject)
Future<List<T>> fetchData<T>({required String uri}) async {
  bool generalException = true;

  final url = Uri.http(socket, uri);
  try {
    var response = await http.get(url)
        .timeout(const Duration(seconds: timeOutSecondsResponse));

    if (response.statusCode == 200) {
      dynamic decodedData = json.decode(response.body);
      if (response.body.isEmpty) return [];
        return (decodedData as List<dynamic>).map((item) => item as T).toList();
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