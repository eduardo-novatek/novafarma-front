import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:novafarma_front/model/enums/data_types_enum.dart';
import 'package:intl/intl.dart';

class CreateTextFormField extends StatefulWidget {
  final bool validate;
  final bool acceptEmpty;
  final String label;
  final int? minValueForValidation;  //si es texto, es el largo minimo. Si es numero, es el valor minimo,...
  final int? maxValueForValidation;
  final String textForValidation; //texto de validacion si esta ocurre
  final DataTypesEnum dataType;
  final int maxLines; //cantidad de lineas 'visibles'
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Function(String)? onChange;
  final List<bool>? validationStates; //lista para el manejo del estado de validacion de todos los textFormField

  const CreateTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.dataType,
    this.validationStates,
    this.maxLines = 1, //solo para campos de texto
    this.focusNode,
    this.validate = true,  //si desea validar el campo
    this.acceptEmpty = false, //si acepta el campo vacío (si validar=true, lo valida solo si no es vacio)
    this.textForValidation = "Por favor, ingrese el dato correcto",
    this.minValueForValidation,
    this.maxValueForValidation,
    this.onChange,
  });

  @override
  State<CreateTextFormField> createState() => _CreateTextFormFieldState();
}

class _CreateTextFormFieldState extends State<CreateTextFormField> {
  late int _index;
  bool _isObscureText = false;

  @override
  void initState() {
    super.initState();

    _index = -1;
    if (widget.validationStates != null) {
      _index = widget.validationStates!.length; // Asignar un índice único
      widget.validationStates!.add(true); // Inicializar el estado de validación
    }
    _isObscureText = (widget.dataType == DataTypesEnum.password);
  }

    @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Stack(
          children: [
            TextFormField (
              focusNode: widget.focusNode,
              controller: widget.controller,
              keyboardType: _determinateInputType(),
              maxLines: widget.dataType == DataTypesEnum.text ? widget.maxLines : 1,
              maxLength:
                  (widget.dataType == DataTypesEnum.text
                      || widget.dataType == DataTypesEnum.password)
                  && widget.maxValueForValidation != null
                      ? widget.maxValueForValidation
                      : null,

              inputFormatters: _determinateMask(),
              decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: TextStyle(fontSize: themeData.textTheme.bodyMedium?.fontSize),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
              ),
              style: TextStyle(
                  fontSize: themeData.textTheme.bodyMedium?.fontSize,
                  color: themeData.colorScheme.primary,
              ),
              obscureText: _isObscureText,

              onChanged: (value) {
                if (widget.onChange != null) {
                  widget.onChange!(value);
                }
              },

              validator: (String? value) {

                if (!widget.validate) return null;
                if (widget.acceptEmpty && value!.trim().isEmpty) return null;

                bool hasError = false;
                if (value!.trim().isEmpty) {
                  hasError = true;

                } else if (widget.dataType == DataTypesEnum.text ||
                    widget.dataType == DataTypesEnum.password){

                  bool errorMin = false;
                  bool errorMax = false;

                  if (widget.minValueForValidation != null){
                    errorMin = (value.trim().length < widget.minValueForValidation!);
                  }
                  if (widget.maxValueForValidation != null){
                    errorMax = (value.trim().length > widget.maxValueForValidation!);
                  }
                  hasError = (errorMin || errorMax);

                } else if (widget.dataType == DataTypesEnum.number ||
                           widget.dataType == DataTypesEnum.telephone) {
                    var number = double.tryParse(value);
                    hasError = (number == null);
                    if (!hasError) {
                      if (widget.minValueForValidation != null) {
                        if (widget.dataType == DataTypesEnum.telephone) {
                          hasError = (
                              value.trim().length < widget.minValueForValidation!);
                        } else { //Es numero
                          hasError = (number < widget.minValueForValidation!);
                        }
                      }
                      if (!hasError && (widget.maxValueForValidation != null)) {
                        if (widget.dataType == DataTypesEnum.telephone) {
                          hasError = (
                              value.trim().length > widget.maxValueForValidation!);
                        } else { //Es numero
                          hasError = (number > widget.maxValueForValidation!);
                        }
                      }
                    }

                } else if (widget.dataType == DataTypesEnum.date) {
                  try {
                    final inputDate = DateFormat('dd/MM/yyyy')
                        .parseStrict(value.trim());
                    hasError =
                        inputDate.isAfter(DateTime.now()) ||
                        inputDate.year < 1900;

                  } catch (e) {
                    hasError = true;
                  }

                }else if (widget.dataType == DataTypesEnum.time) {
                  try {
                    final RegExp regExp =
                      RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
                    hasError = ! regExp.hasMatch(value.trim());

                  } catch (e) {
                    hasError = true;
                  }

                } else if (widget.dataType == DataTypesEnum.email) {
                    final emailRegExp =
                      RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                    hasError = !emailRegExp.hasMatch(value.trim());

                } else if (widget.dataType == DataTypesEnum.identificationDocument) {
                    hasError = ! _validateDocument(value.trim());
                }

                // Actualizar el estado de validación correspondiente a esta instancia
                if (widget.validationStates != null) {
                  widget.validationStates![_index] = !hasError;
                }

                if (hasError){
                  widget.focusNode?.requestFocus();
                  return widget.textForValidation;
                }
                return null;
              },
            ),

            Positioned(
              right: 0,
              top: 10,
              child: widget.dataType == DataTypesEnum.password
                  ? IconButton(
                        onPressed: () {
                            setState(() {
                              _isObscureText = ! _isObscureText;
                            });
                        },
                        icon: Icon(
                          _isObscureText ? Icons.visibility : Icons.visibility_off,
                        )
                    )

                  : const SizedBox.shrink(),

              ),
          ],
        );

  }

  //"document" Debe incluir el digito verificador
  bool _validateDocument(String? document) {
    if (document == "00000000") return true; //valida este documento para fines especificos
    if (document!.length < 7 || document.length > 8) return false;
    if (double.tryParse(document) == null) return false;
    if (_equalDigits(document)) return false;

    List<int> controlList;
    document.length == 8
      ? controlList = [8,1,2,3,4,7,6]
      : controlList = [1,2,3,4,7,6];

    List<int> digits = _toListInteger(document);
    int x = 0;

    // Omito el digito verificador
    for(int i = 0; i < document.length-1; i++) {
      x += digits[i] * controlList[i];
    }
    return ((x % 10) == digits[digits.length-1]);
  }

  bool _equalDigits(String document) {
    final first = document[0];
    for (var i = 1; i < document.length; i++) {
      if (document[i] != first) {
        return false;
      }
    }
    return true;
  }

  List<int> _toListInteger(String str) {
    List<int> ret = List.generate(str.length, (index) => 0);
    for(int i = 0; i < ret.length; i++) {
      ret[i] = int.parse(str[i]);
    }
    return ret;
  }

  TextInputType _determinateInputType(){
    if (widget.dataType == DataTypesEnum.identificationDocument ||
        widget.dataType == DataTypesEnum.number ||
        widget.dataType == DataTypesEnum.telephone) return TextInputType.number;

    if (widget.dataType == DataTypesEnum.date ||
        widget.dataType == DataTypesEnum.time) return TextInputType.datetime;

    if (widget.dataType == DataTypesEnum.email) return TextInputType.emailAddress;

    if (widget.dataType == DataTypesEnum.text && widget.maxLines > 1) {
      return TextInputType.multiline;
    }

    return TextInputType.text;
  }

  List<MaskTextInputFormatter> _determinateMask() {
    if (widget.dataType == DataTypesEnum.date) {
      return [MaskTextInputFormatter(mask: '##/##/####')];
    }
    return [];
  }

}
