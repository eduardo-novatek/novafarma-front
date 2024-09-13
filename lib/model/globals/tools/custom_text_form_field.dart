import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:intl/intl.dart';

class CustomTextFormField extends StatefulWidget {
  final bool validate;
  final bool enabled;
  final bool acceptEmpty;
  final String label;
  final double? minValueForValidation;  //si es texto, es el largo minimo. Si es numero, es el valor minimo,...
  final double? maxValueForValidation;
  final String? textForValidation; //texto de validacion si ocurre un error
  final DataTypeEnum dataType;
  final bool? viewCharactersCount; //Mostrar contador de caracteres
  final int maxLines; //cantidad de lineas 'visibles'
  final bool? isUnderline; // Underline=true: coloca una linea debajo del texto (false: la linea rodea el texto)
  final TextEditingController controller;
  final bool? initialFocus; //Si debe tener el foco inicial (por defecto es false. Debe ser true solo 1 TextFormField del formulario)
  final FocusNode? focusNode;
  final TextStyle? textStyle;
  final InputDecoration? decoration;
  final List<bool>? validationStates; //lista para el manejo del estado de validacion de todos los textFormField
  final Function(String)? onChange;
  final Function(String)? onFieldSubmitted;
  final VoidCallback? onEditingComplete; //Se utiliza VoidCallBack para funciones sin paramentros que no devuelven un valor

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.dataType,
    this.enabled = true,
    this.validationStates,
    this.maxLines = 1, //solo para campos de texto
    this.viewCharactersCount = true,
    this.isUnderline = true, //solo para campos de texto
    this.validate = true,  //si desea validar el campo
    this.acceptEmpty = false, //si acepta el campo vacío (si validar=true, lo valida solo si no es vacio)
    this.initialFocus = false,
    this.textForValidation = "Por favor, ingrese el dato correcto",
    this.minValueForValidation,
    this.maxValueForValidation,
    this.onChange,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.focusNode,
    this.textStyle,
    this.decoration,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late int _index;
  bool _isObscureText = false;
  //bool _focusForward = true;

  @override
  void initState() {
    super.initState();

    _index = -1;
    if (widget.validationStates != null) {
      _index = widget.validationStates!.length; // Asignar un índice único
      widget.validationStates!.add(true); // Inicializar el estado de validación
    }
    _isObscureText = (widget.dataType == DataTypeEnum.password);
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Stack(
      children: [
        TextFormField (
          focusNode: widget.focusNode,
          controller: widget.controller,
          enabled: widget.enabled,
          autofocus: widget.initialFocus!,
          //autofillHints: _determinateAutofill(),
          keyboardType: _determinateInputType(),
          maxLines: widget.dataType == DataTypeEnum.text ? widget.maxLines : 1,
          maxLength: _maxLength(),
          inputFormatters: _determinateMask(),
          decoration: _buildInputDecoration(themeData),
          style: widget.textStyle ?? TextStyle(
              fontSize: themeData.textTheme.bodyMedium?.fontSize,
              color: themeData.colorScheme.primary,
          ),
          obscureText: _isObscureText,
          onChanged: (value) {
           if (widget.onChange != null) widget.onChange!(value);
          },
          onFieldSubmitted: (value) {
            if (widget.onFieldSubmitted != null) widget.onFieldSubmitted!(value);
          },
          onEditingComplete: () {
            if (widget.onEditingComplete != null) widget.onEditingComplete!();
          },
          validator: (String? value) {

            if (!widget.validate) return null;
            if (widget.acceptEmpty && value!.trim().isEmpty) return null;

            bool hasError = false;
            if (value!.trim().isEmpty) {
              hasError = true;

            } else if (widget.dataType == DataTypeEnum.text ||
                widget.dataType == DataTypeEnum.password){

              bool errorMin = false;
              bool errorMax = false;

              if (widget.minValueForValidation != null){
                errorMin = (value.trim().length < widget.minValueForValidation!);
              }
              if (widget.maxValueForValidation != null){
                errorMax = (value.trim().length > widget.maxValueForValidation!);
              }
              hasError = (errorMin || errorMax);

            } else if (widget.dataType == DataTypeEnum.number ||
                       widget.dataType == DataTypeEnum.telephone) {
                var number = double.tryParse(value);
                hasError = (number == null);
                if (!hasError) {
                  if (widget.minValueForValidation != null) {
                    if (widget.dataType == DataTypeEnum.telephone) {
                      hasError = (
                          value.trim().length < widget.minValueForValidation!);
                    } else { //Es numero
                      hasError = (number < widget.minValueForValidation!);
                    }
                  }
                  if (!hasError && (widget.maxValueForValidation != null)) {
                    if (widget.dataType == DataTypeEnum.telephone) {
                      hasError = (
                          value.trim().length > widget.maxValueForValidation!);
                    } else { //Es numero
                      hasError = (number > widget.maxValueForValidation!);
                    }
                  }
                }

            } else if (widget.dataType == DataTypeEnum.date) {
              try {
                final inputDate = DateFormat('dd/MM/yyyy')
                    .parseStrict(value.trim());
                hasError =
                    inputDate.isAfter(DateTime.now()) ||
                    inputDate.year < 1900;
              } catch (e) {
                hasError = true;
              }

            }else if (widget.dataType == DataTypeEnum.time) {
              try {
                final RegExp regExp =
                  RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
                hasError = ! regExp.hasMatch(value.trim());

              } catch (e) {
                hasError = true;
              }

            } else if (widget.dataType == DataTypeEnum.email) {
                final emailRegExp =
                  RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                hasError = !emailRegExp.hasMatch(value.trim());

            } else if (widget.dataType == DataTypeEnum.identificationDocument) {
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
          top: 7,
          child: widget.dataType == DataTypeEnum.password
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


  InputDecoration _buildInputDecoration(ThemeData themeData) {
      return widget.decoration == null
        ? InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(fontSize: themeData.textTheme.bodyMedium?.fontSize),
            counter: widget.viewCharactersCount! ? null : const SizedBox.shrink(),
            contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
            border: widget.isUnderline!
              ? const UnderlineInputBorder()
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )
          )
        : widget.decoration!;
  }

    int? _maxLength() {
      return (widget.dataType == DataTypeEnum.text
                    || widget.dataType == DataTypeEnum.password
                      || widget.dataType == DataTypeEnum.email)
                && widget.maxValueForValidation != null
                    ? widget.maxValueForValidation?.toInt()
                    : null;
    }

  //"document" Debe incluir el digito verificador
  bool _validateDocument(String? document) {
    //if (document == "00000000") return true; //valida este documento para fines especificos
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
    if (widget.dataType == DataTypeEnum.identificationDocument ||
        widget.dataType == DataTypeEnum.number ||
        widget.dataType == DataTypeEnum.telephone) return TextInputType.number;

    if (widget.dataType == DataTypeEnum.date ||
        widget.dataType == DataTypeEnum.time) return TextInputType.datetime;

    if (widget.dataType == DataTypeEnum.email) return TextInputType.emailAddress;

    if (widget.dataType == DataTypeEnum.text && widget.maxLines > 1) {
      return TextInputType.multiline;
    }

    return TextInputType.text;
  }

  List<TextInputFormatter> _determinateMask() {
    if (widget.dataType == DataTypeEnum.date) {
      return [MaskTextInputFormatter(mask: '##/##/####')];
    } else if (widget.dataType == DataTypeEnum.number) {
      return [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),];
    } else if (widget.dataType == DataTypeEnum.text) {
      return [FilteringTextInputFormatter.allow(
        RegExp(r'[a-zA-Z0-9\s().:,!\-_ñÑáéíóúÁÉÍÓÚ]')
      )];
    }
    return [];
  }

  /*List<String>? _determinateAutofill() {
    if (widget.dataType == DataTypeEnum.password ||
        widget.dataType == DataTypeEnum.date ||
        widget.dataType == DataTypeEnum.time
    ) {
      return null; // No se sugiere autocompletar
    }

    switch (widget.dataType) {
      case DataTypeEnum.email:
        return [AutofillHints.email];
      case DataTypeEnum.number || DataTypeEnum.identificationDocument:
        return [AutofillHints.transactionAmount];
      //case DataTypeEnum.date:
      //  return [AutofillHints.birthday];
      case DataTypeEnum.telephone:
        return [AutofillHints.telephoneNumber];
      case DataTypeEnum.text:
      default:
        return [AutofillHints.name]; // Texto generico
    }
  }*/

/*List<MaskTextInputFormatter> _determinateMask() {
    if (widget.dataType == DataTypeEnum.date) {
      return [MaskTextInputFormatter(mask: '##/##/####')];
    }
    return [];
  }*/

  // Esta funcion se deshabilito porque es para validar fechas enteras,
  // (no se ajusta al onChange)
  /*bool _validateDate(String date) {
    final RegExp dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(date)) return false;
    return true;
  }*/

}
