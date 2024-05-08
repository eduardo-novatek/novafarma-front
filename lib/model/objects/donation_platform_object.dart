import 'package:pf_care_front/model/globals/deserializable.dart';

class DonationPlatformObject implements Deserializable <DonationPlatformObject> {
  final bool? isFirst;
  final int? id;
  final String? name;
  final String? description;
  final DateTime? dateCreated;
  final int? state; //1: publicado, 2: solicitado (pasarlo a enumerado...)
  final int? requestCount;

  DonationPlatformObject.empty():
        isFirst = null, id = null, name = null, description = null,
        dateCreated = null, state = null, requestCount = null;

  DonationPlatformObject({
    this.isFirst = false, this.id, this.name, this.description, this.dateCreated,
    this.state, this.requestCount
  });

  @override
   fromJson(Map<String, dynamic> json) {
    return DonationPlatformObject(
      id: json['eq_id'],
      name: json['eq_name'],
      description: json['eq_description'],
      dateCreated: json['eq_created_at'] != null
          ? DateTime.parse(json['eq_created_at'])
          : null,
      state: json['state'],
      requestCount: json['request_count'],
    );
  }
}

