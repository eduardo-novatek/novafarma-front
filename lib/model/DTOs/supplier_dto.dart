import 'package:novafarma_front/model/globals/deserializable.dart';

class SupplierDTO extends Deserializable<SupplierDTO> {
  late final int? supplierId;
  late final String name;
  late final String? telephone1;
  late final String? telephone2;
  late final String? address;
  late final String? email;
  late final String? notes;
  late final bool? isFirst;

  SupplierDTO.empty():
        supplierId = null,
        name = "",
        telephone1 = "",
        telephone2 = "",
        address = "",
        email = "",
        notes = "",
        isFirst = false
  ;

  SupplierDTO({
    this.supplierId,
    this.telephone1,
    this.telephone2,
    this.address,
    this.email,
    this.notes,
    this.isFirst,
    required this.name,
  });

  @override
  SupplierDTO fromJson(Map<String, dynamic> json) {
    return SupplierDTO(
      supplierId: json['supplierId'],
      name: json['name'],
      telephone1: json['telephone1'],
      telephone2: json['telephone2'],
      address: json['address'],
      email: json['email'],
      notes: json['notes'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'name': name,
      'telephone1': telephone1,
      'telephone2': telephone2,
      'address': address,
      'email': email,
      'notes': notes,
    };
  }

  @override
  String toString() {
    return name;
  }
}
