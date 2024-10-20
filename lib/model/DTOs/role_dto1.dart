import 'package:novafarma_front/model/globals/deserializable.dart';

class RoleDTO1 extends Deserializable<RoleDTO1> {
  int? roleId;
  String? name;
  //List<TaskDTO>? taskList;

  RoleDTO1.empty():
    roleId = null,
    name = null;
    //taskList = null;

  RoleDTO1({
    required this.roleId,
    required this.name,
   // required this.taskList
  });

  @override
  RoleDTO1 fromJson(Map<String, dynamic> json) {
    return RoleDTO1(
      roleId: json['roleId'],
      name: json['name'],
      //taskList: json['taskList']
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'name': name,
      //'taskList': taskList?.map((item) => item.toJson()).toList(),
    };
  }

}