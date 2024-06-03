import 'package:intl/intl.dart';

DateTime? parseDate(String? dateString) {
  if (dateString!.isEmpty) return null;
  try {
    return DateFormat('dd/MM/yyyy').parse(dateString);
  } catch (e) {
    return null;
    //throw('Error convirtiendo fecha: $e');
  }
}