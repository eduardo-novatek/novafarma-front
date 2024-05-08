import 'package:novafarma_front/model/globals/publics.dart';

///Dado el nombre de un rol en userLogged, devuelve su entityId, o null si
///no lo encuentra.
String? userLoggedObtainEntityIdByRole(String role) {
  for (int i = 0; i < userLogged["roles"].length; i++) {
    if (userLogged["roles"][i]["rol"] == role){
      return userLogged["roles"][i]["entityId"];
    }
  }
  return null;
}
