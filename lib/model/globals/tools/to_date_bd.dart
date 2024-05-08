
import 'package:intl/intl.dart';

String toDateBD(String dateDMY) {
  final inputDateFormat = DateFormat('dd/MM/yyyy');
  final outputDateFormat = DateFormat('yyyy-MM-dd');
  final inputDate = inputDateFormat.parseStrict(dateDMY);
  return outputDateFormat.format(inputDate);
}