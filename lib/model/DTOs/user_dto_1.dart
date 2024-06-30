import 'package:novafarma_front/model/globals/deserializable.dart';

class UserDTO1 extends Deserializable<UserDTO1> {
  int? userId;

  UserDTO1({required this.userId});

  UserDTO1.empty(): userId = 0;

  @override
  UserDTO1 fromJson(Map<String, dynamic> json) {
    return UserDTO1(userId: json['userId']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'userId': userId};
  }

}