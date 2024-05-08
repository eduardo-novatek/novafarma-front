import 'package:pf_care_front/model/enums/formal_caregiver_enum.dart';

class FormalCareObject {
  final FormalCareEnum? formalCareEnum;
  final String label;
  final bool isFirst;

  FormalCareObject({
    this.isFirst = false,
    this.formalCareEnum,
    required this.label
  });

  @override
  String toString() {
    return label;
  }
}