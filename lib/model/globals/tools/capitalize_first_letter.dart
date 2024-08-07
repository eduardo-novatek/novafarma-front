///Convierte el texto a minusculas, salvo el primer caracter que pasa a mayusculas
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}