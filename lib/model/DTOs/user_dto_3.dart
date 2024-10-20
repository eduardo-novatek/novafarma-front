import 'package:novafarma_front/model/DTOs/role_dto4.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';

class UserDTO3 extends Deserializable<UserDTO3> {
  int? userId;
  String? name;
  String? lastname;
  String? userName;
  RoleDTO4? role;
  String? token;

  UserDTO3.empty():
    userId = null,
    name = null,
    lastname = null,
    userName = null,
    role = RoleDTO4.empty(),
    token = null;


  UserDTO3({
    this.userId,
    required this.name,
    required this.lastname,
    required this.userName,
    required this.role,
    required this.token,
  });

  @override
  UserDTO3 fromJson(Map<String, dynamic> json) {
    return UserDTO3(
      userId: json['userId'],
      name: json['name'],
      lastname: json['lastname'],
      userName: json['userName'],
      role: role?.fromJson(json['role']),
      token: json['jwt'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'lastname': lastname,
      'role': role?.toJson(),
      'token': token,
      'userName': userName,
    };
  }
}
