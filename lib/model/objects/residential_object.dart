import '../globals/deserializable.dart';

class ResidentialObject implements Deserializable <ResidentialObject> {
  final String name;
  final String? id;
  final bool? isFirst;

  ResidentialObject.empty(): id = null, name = "", isFirst = null;

  ResidentialObject({
    this.isFirst = false,
    this.id,
    required this.name
  });

  @override
  ResidentialObject fromJson(Map<String, dynamic> json) {
    return ResidentialObject(
      id: json['residentialId'],
      name: json['name'],
    );
  }

  @override
  String toString() {
    return name;
  }

}
