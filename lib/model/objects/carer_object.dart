import 'day_time_range_object.dart';

class CarerObject {
  String name;
  String? surname;

  // Dias y rangos horarios semanales disponibles para el cuidado.
  // Si el cuidador tiene disponibilidad 24x7, dayTimeRange=[]
  // Si se omite, se asume dayTimeRange=[]
  List<DayTimeRangeObject>? dayTimeRange;

  CarerObject({
    required this.name,
    this.surname,
    required this.dayTimeRange
  });
}
