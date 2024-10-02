import 'package:novafarma_front/model/globals/deserializable.dart';

class SupplierDTO extends Deserializable<SupplierDTO> {
  int? supplierId;
  String name;
  String? telephone1;
  String? telephone2;
  String? address;
  String? email;
  String? notes;
  bool? isFirst;
  bool? deleted;

  SupplierDTO.empty():
        supplierId = null,
        name = "",
        telephone1 = "",
        telephone2 = "",
        address = "",
        email = "",
        notes = "",
        isFirst = false,
        deleted = false
  ;

  SupplierDTO({
    this.supplierId,
    this.telephone1,
    this.telephone2,
    this.address,
    this.email,
    this.notes,
    this.isFirst,
    this.deleted,
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
      deleted: json['deleted'],
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
      'deleted': deleted,
    };
  }

  @override
  String toString() {
    return name;
  }
}
