enum RoleEnum {
  patient,
  referenceCare,          // Cuidador Referente
  formalCare,             // Cuidador formal
  volunteerPerson,
  volunteerCompany
}

///Dado un RoleEnum, devuelve el nombre del rol. Si es para bases de datos
///devuelve el string adecuado, sino, lo devuelve apropiado para usar en pantalla
String nameRole({
  required RoleEnum roleEnum,
  bool forDatabases = false}) {

  switch (roleEnum) {
    case RoleEnum.patient:
      return forDatabases ? "PATIENT" : "Paciente";
    case RoleEnum.referenceCare:
      return forDatabases ? "REFERENCE_CARE" : "Cuidador referente";
    case RoleEnum.formalCare:
      return forDatabases ? "FORMAL_CARE" :"Cuidador formal";
    case RoleEnum.volunteerPerson:
      return forDatabases ? "VOLUNTEER_PERSON" : "Persona voluntaria";
    case RoleEnum.volunteerCompany:
      return forDatabases ? "VOLUNTEER_COMPANY" : "Empresa voluntaria";
  default: return "";
  }
}
///Dado un rol de base de datos, devuelve un RoleEnum
RoleEnum? roleDBToEnum(String roleDataBases){
  switch (roleDataBases) {
    case "PATIENT": return RoleEnum.patient;
    case "FORMAL_CARE":  return RoleEnum.formalCare;
    case "REFERENCE_CARE": return RoleEnum.referenceCare;
    case "VOLUNTEER_PERSON": return RoleEnum.volunteerPerson;
    case "VOLUNTEER_COMPANY": return RoleEnum.volunteerCompany;
  }
  return null;
}
