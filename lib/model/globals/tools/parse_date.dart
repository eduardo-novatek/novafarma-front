import 'package:intl/intl.dart';

DateTime? parseDate(String? dateString) {
  if (dateString == null) return null;
  try {
    return DateFormat('dd/MM/yyyy').parse(dateString);
  } catch (e) {
    throw('Error convirtiendo fecha: $e');
  }
}