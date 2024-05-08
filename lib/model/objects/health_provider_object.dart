import 'package:pf_care_front/model/globals/deserializable.dart';

class HealthProviderObject implements Deserializable <HealthProviderObject> {
  final String? id;
  final String name;
  final bool? isFirst;

  HealthProviderObject.empty(): id = null, name = "", isFirst = null;

  HealthProviderObject({
    required this.name,
    this.isFirst = false,
    this.id
  });

  @override
  HealthProviderObject fromJson(Map<String, dynamic> json) {
    return HealthProviderObject(
      id: json['healthProviderId'],
      name: json['name'],
    );
  }

  @override
  String toString() {
    return name;
  }
}
