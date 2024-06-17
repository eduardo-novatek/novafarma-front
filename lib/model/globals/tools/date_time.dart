import 'package:intl/intl.dart';

DateTime? strToDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;

  DateTime? date;
  // Intentar parsear en formato yyyy-MM-dd
  try {
    //date = DateTime.parse(dateString);
    date = DateTime.parse(dateString);
  } catch (_) {
    // Si falla, intentar parsear en formato dd/MM/yyyy
    try {
      date = DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      print('Error al analizar la fecha: $e');
      return null;
    }
  }
  return date;

  /*if (dateString!.isEmpty) return null;
  try {
    return DateFormat('dd/MM/yyyy').parse(dateString);
  } catch (e) {
    return null;
  }*/
}

String? dateToStr(DateTime? dateTime) {
  if (dateTime == null) return null;
  try {
    return  DateFormat('dd/MM/yyyy').format(dateTime);
  } catch (e) {
    return null;
  }
}
