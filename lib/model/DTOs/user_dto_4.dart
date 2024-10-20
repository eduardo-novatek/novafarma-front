import 'package:novafarma_front/model/globals/deserializable.dart';

class UserDTO4 extends Deserializable{
  String? userName;
  String? password;

  UserDTO4({
    required this.userName,
    required this.password,
  });

  UserDTO4.empty():
        userName = null,
        password = null;

  @override
  fromJson(Map<String, dynamic> json) {
    return UserDTO4(
      userName: json['userName'],
      password: json['password']
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'password': password
    };
  }
}
