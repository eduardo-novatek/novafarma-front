import '../globals/deserializable.dart';

class EmergencyServicesObject implements Deserializable <EmergencyServicesObject> {
  final String name;
  final String? id;
  final bool? isFirst;

  EmergencyServicesObject.empty(): id = null, name = "", isFirst = null;

  EmergencyServicesObject({
    this.isFirst = false,
    this.id,
    required this.name
  });

  @override
  EmergencyServicesObject fromJson(Map<String, dynamic> json) {
    return EmergencyServicesObject(
      id: json['emergencyServiceId'],
      name: json['name'],
    );
  }

  @override
  String toString() {
    return name;
  }

}
