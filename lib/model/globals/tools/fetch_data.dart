import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:novafarma_front/model/globals/handle_response.dart';
import 'package:novafarma_front/model/globals/publics.dart';

import '../../objects/error_object.dart';
import '../constants.dart' show socket, timeOutSecondsResponse;

///Devuelve una List<T> del endpoint especificado (solo get). El tipo de datos
///debe ser un primitivo (para objetos usar fetchDataObject)
Future<List<T>> fetchData<T>({required String uri}) async {
  bool generalException = true;

  final url = Uri.http(socket, uri);
  try {
    var response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${userLogged!.token}'}
    ).timeout(const Duration(seconds: timeOutSecondsResponse));

    if (response.statusCode == 200) {
      dynamic decodedData = json.decode(response.body);
      if (response.body.isEmpty) return [];
        return (decodedData as List<dynamic>).map((item) => item as T).toList();
    } else {
      generalException = false;
      throw handleResponse(response);
    }

  } catch (e) {
    if (generalException) {
      rethrow;
    }
    return Future.error(e);
  }

}