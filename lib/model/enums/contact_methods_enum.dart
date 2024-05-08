enum ContactMethodsEnum {
  call,           // Llamada
  whatsapp,       // WhatsApp
  telegram,       // Telegram
  sms,
  mail,
}


String nameContactMethod({
  required ContactMethodsEnum contactMethodsEnum,
  bool forDatabases = false}) {

  switch (contactMethodsEnum) {
    case ContactMethodsEnum.call: return forDatabases ? "CALL" : "Llamada";
    case ContactMethodsEnum.whatsapp: return forDatabases ? "WHATSAPP" : "WhatsApp";
    case ContactMethodsEnum.telegram: return forDatabases ? "TELEGRAM" : "Telegram";
    case ContactMethodsEnum.sms: return forDatabases ? "SMS" : "SMS";
    case ContactMethodsEnum.mail: return forDatabases ? "MAIL" : "e-mail";
    default: return "";
  }
}

String contactMethodNameToDB({required String contactMethod}) {
  switch (contactMethod) {
    case "Llamada": return "CALL";
    case "WhatsApp": return "WHATSAPP";
    case "Telegram": return "TELEGRAM";
    case "SMS": return "SMS";
    case "e-mail": return "MAIL";
    default: return "";
  }
}

///Dado un genero de base de datos, devuelve un PersonGenderEnum
ContactMethodsEnum? contactMethodDBToEnum(String contactMethodDataBases){
  switch (contactMethodDataBases) {
    case "CALL": return ContactMethodsEnum.call;
    case "WHATSAPP": return ContactMethodsEnum.whatsapp;
    case "TELEGRAM": return ContactMethodsEnum.telegram;
    case "SMS": return ContactMethodsEnum.sms;
    case "MAIL": return ContactMethodsEnum.mail;
  }
  return null;
}

///Dado un genero de base de datos, devuelve un String
String? contactMethodDBToString(String contactMethodDataBases){
  switch (contactMethodDataBases) {
    case "CALL": return "Llamada";
    case "WHATSAPP": return "WhatsApp";
    case "TELEGRAM": return "Telegram";
    case "SMS": return "SMS";
    case "MAIL": return "e-mail";
  }
  return null;
}
