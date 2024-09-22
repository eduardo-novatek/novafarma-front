import 'package:novafarma_front/model/DTOs/task_dto.dart';
import 'package:novafarma_front/model/globals/deserializable.dart';
import 'package:novafarma_front/model/DTOs/role_dto.dart';

import '../enums/task_enum.dart';

class UserDTO extends Deserializable<UserDTO> {
  int? userId;
  String? name;
  String? lastname;
  String? userName;
  String? pass;
  bool? active;
  bool? changeCredentials;
  RoleDTO? role;

  UserDTO.empty():
        userId = null,
        name = null,
        lastname = null,
        userName = null,
        pass = null,
        active = null,
        changeCredentials = null,
        role = RoleDTO.empty();

  UserDTO({
    this.userId,
    this.name,
    this.lastname,
    this.userName,
    this.pass,
    this.active,
    this.changeCredentials,
    this.role,
  });

  @override
  UserDTO fromJson(Map<String, dynamic> json) {
    return UserDTO(
      userId: json['userId'],
      name: json['name'],
      lastname: json['lastname'],
      userName: json['userName'],
      pass: json['pass'],
      active: json['active'],
      changeCredentials: json['changeCredentials'],
      role: json['role'] != null ? getRoleDTO(json) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'lastname': lastname,
      'userName': userName,
      'pass': pass,
      'active': active,
      'changeCredentials': changeCredentials,
      'role': role?.toJson(),
    };
  }

  RoleDTO getRoleDTO(Map<String, dynamic> json) {
    return RoleDTO(
      roleId: json['role']['roleId'],
      name: json['role']['name'],
      taskList: json['role']['taskList'] != null ? _getTaskDTOList(json) : null,
    );
  }

  List<TaskDTO> _getTaskDTOList(Map<String, dynamic> json) {
    return List<TaskDTO>.from(
        json['role']['taskList'].map((item) => TaskDTO(
          taskId: item['taskId'],
          task: toTaskEnumFromBackend(item['task']),
          description: item['description'],
        ))
    );
  }
}
