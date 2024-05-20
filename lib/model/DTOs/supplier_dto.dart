import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/DTOs/role_dto.dart';

class SupplierDTO extends Deserializable<SupplierDTO> {
  final int? supplierId;
  final String name;
  final String? telephone1;
  final String? telephone2;
  final String? address;
  final String? email;
  final String? notes;
  final bool? isFirst;

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
