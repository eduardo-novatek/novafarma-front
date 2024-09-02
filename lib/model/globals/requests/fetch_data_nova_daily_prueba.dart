import 'package:http/http.dart' as http;

import '../../enums/request_type_enum.dart';
import '../deserializable.dart';

Future<List<Object>?> fetchDataNovaDailyPrueba<T extends Deserializable<T>>({
  required String url,
  required T classObject,
  RequestTypeEnum? requestType = RequestTypeEnum.get,
  Object? body,
}) async {
  try {
    // Realiza la solicitud GET usando la biblioteca http
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Procesar la respuesta como se hace normalmente
      print(response.body);
      // Aquí puedes agregar tu lógica de deserialización de datos
      // Ejemplo:
      // return parseResponse(response.body, classObject);
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Request failed: $e');
  }
  return null;
}
