import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

///Dada una fecha en formato String (dateStr), devuelve la fecha en formato
///DateTime. Si el argumento dateStr es "yyyy-MM-dd", devuelve un objeto
///DateTime con igual formato. Idem para dateStr="dd/MM/yyyy".
///Si falla la conversión o el año < 1900, retorna null.
DateTime? strToDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  DateTime? date;
  // Intentar parsear en formato yyyy-MM-dd
  try {
    date = DateTime.parse(dateStr);
  } catch (_) {
    // Si falla, intentar parsear en formato dd/MM/yyyy
    try {
      date = DateFormat('dd/MM/yyyy').parseStrict(dateStr);
    } catch (e) {
      if (kDebugMode) print('Error parseando la fecha: $e');
      return null;
    }
  }
  if (date.year < 1900) return null;
  return date;
}

///Dada una fecha en formato DateTime: yyyy-MM-dd, la devuelve en formato String
/// como "dd/MM/yyyy". Si la fecha es nula o no pudo convertir, devuelve null.
String? dateToStr(DateTime? date) {
  if (date == null) return null;
  try {
    return  DateFormat('dd/MM/yyyy').format(date);
  } catch (e) {
    return null;
  }
}

///Dada una fecha en formato de visualización de tipo String: "dd/MM/yyyy",
///la devuelve en formato String: "yyyy-MM-dd"
String strDateViewToStrDate(String dateDMY) {
  return DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parseStrict(dateDMY));
}

///Dada una fecha en formato DateTime de tipo String: "yyyy-MM-dd" la devuelve
///en formato de visualización de tipo String: "dd/MM/yyyy"
String strDateToStrDateView(String dateYMD) {
  return DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parseStrict(dateYMD));
}
