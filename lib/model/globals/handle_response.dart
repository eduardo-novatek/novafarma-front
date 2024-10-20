
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../objects/error_object.dart';

ErrorObject handleResponse(http.Response response) {
  try {
    return ErrorObject(
      statusCode: response.statusCode,
      message: jsonDecode(response.body)['message'],
    );
  } catch (e) {
    // Para los casos en que la respuesta venga como texto plano
    return ErrorObject(
      statusCode: response.statusCode,
      message: response.body.isNotEmpty ? response.body : null,
    );
  }
}
