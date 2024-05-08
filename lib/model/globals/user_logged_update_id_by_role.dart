import 'package:novafarma_front/model/globals/publics.dart' show userLogged;

///Dado el nombre de un rol en userLogged, actualiza su entityId. Si existe
///lo sobreescribe
void userLoggedUpdateIdByRole({required String role, required String entityId}) {
  for (int i = 0; i < userLogged["roles"].length; i++) {
    if (userLogged["roles"][i]["rol"] == role) {
      userLogged["roles"][i]["entityId"] = entityId;
    }
  }
}
