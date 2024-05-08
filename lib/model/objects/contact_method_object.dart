import 'package:pf_care_front/model/enums/contact_methods_enum.dart';

class ContactMethodObject {
  final ContactMethodsEnum? contactMethodsEnum;
  final String label;
  final bool isFirst;

  ContactMethodObject({
    this.isFirst = false,
    this.contactMethodsEnum,
    required this.label
  });

  @override
  String toString() {
    return label;
  }
}