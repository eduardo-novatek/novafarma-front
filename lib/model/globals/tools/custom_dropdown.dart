import 'package:flutter/material.dart';

import '../constants.dart' show menuMaxHeight;

///Clase genérica para la construcción de un DropDown.
///Ejemplo de uso: primero creamos la clase base con un metodo toString, el
///que debe devolver el atributo que se desea mostrar en el dropDown:
///
///class PersonGenderObject {
///     final PersonGenderEnum? personGenderEnum;
///     final String label;
///     final bool isFirst;
///
///     PersonGenderObject({
///          this.isFirst = false,
///         this.personGenderEnum,
///          required this.label
///       });
///
///     @override
///     String toString() {
///       return label;
///     }
/// }
///
///Para utilizarla:
///
///List<PersonGenderObject> personGenderList = [
///     PersonGenderObject(isFirst: true, label: "Seleccione..."),
///     PersonGenderObject(personGenderEnum: PersonGenderEnum.MALE, label: "Masculino"),
/// ];
///
/// Widget _drawDropDownGender(String text) {
///     return CustomDropdown<PersonGenderObject>(
///       themeData: themeData,
///       optionList: personGenderList,
///       selectedOption: personGendersList[0],
///       callback: (gender) {
///         print(gender);
///       });
///   }

class CustomDropdown<T extends Object> extends StatefulWidget {

  final ThemeData themeData;
  final List<T?> optionList;
  final T? selectedOption;
  final bool isSelected; //true: 'selectedOption' queda seleccionada. false: la 1er opcion queda seleccionada
  final Function(T?) callback;
  final FocusNode? focusNode;

  const CustomDropdown({
        super.key,
        this.focusNode,
        required this.themeData,
        required this.optionList,
        required this.selectedOption,
        required this.isSelected,
        required this.callback,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T extends Object> extends State<CustomDropdown<T>> {

  T? object;

  @override
  void initState() {
    super.initState();
    //object = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    object = widget.selectedOption;

    return Focus(
      focusNode: widget.focusNode,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DropdownButton<T>(
          menuMaxHeight: menuMaxHeight,
          dropdownColor: widget.themeData.colorScheme.secondaryContainer,
          style: TextStyle(
            color: widget.themeData.primaryColor,
            fontSize: widget.themeData.textTheme.bodyMedium?.fontSize,
          ),
          isDense: true,
          value: widget.isSelected ? object : widget.optionList[0],
          items: widget.optionList.map((T? value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Text(value != null ? value.toString() : ''),
            );
          }).toList(),

          onChanged: (val) {
            widget.callback(val);
            /*setState(() {
              object = val;
            });*/
          },
        ),
      ),
    );
  }

}
