import 'package:intl/intl.dart';

DateTime? toDate(String? dateString) {
  if (dateString!.isEmpty) return null;
  try {
    return DateFormat('dd/MM/yyyy').parse(dateString);
  } catch (e) {
    return null;
  }
}

String? toDateStr(DateTime? dateTime) {
  if (dateTime == null) return null;
  try {
    return  DateFormat('dd/MM/yyyy').format(dateTime);
  } catch (e) {
    return null;
  }
}
