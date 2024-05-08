import 'package:pf_care_front/model/objects/time_range_object.dart';

import '../enums/days_week_enum.dart';

class DayTimeRangeObject {
  DaysWeekEnum? day;
  List<TimeRangeObject>? timeRange;

  DayTimeRangeObject({
    required this.day,
    required this.timeRange
  });
}