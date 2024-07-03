// ignore_for_file: use_build_context_synchronously, must_be_immutable, avoid_web_libraries_in_flutter

import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/build_circular_progress.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';

import '../../model/DTOs/customer_dto1.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/requests/fetch_customer_list.dart';
import '../../model/globals/tools/floating_message.dart';
import '../dialogs/customer_selection_dialog.dart';

class CustomerBox extends StatefulWidget {
  String? customerSelected; //Nombre+Apellido+Documento del cliente seleccionado
  final FocusNode? nextFocusNode; // Proximo textFormField para dar el foco
  final ValueChanged<CustomerDTO1?> onSelectedChanged;

  CustomerBox({
    super.key,
    required this.customerSelected,
    required this.onSelectedChanged,
    this.nextFocusNode,
  });

  @override
  CustomerBoxState createState() => CustomerBoxState();
}

class CustomerBoxState extends State<CustomerBox> {

  final _formKey = GlobalKey<FormState>();

  final List<CustomerDTO1> _customerList = [];

  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();

  final FocusNode _documentFocusNode = FocusNode();
  final FocusNode _lastnameFocusNode = FocusNode();

  bool _isLoading = false;

  //guarda los datos del cliente encontrado ("JUAN PEREZ (12345678)")
  //String? _customerFound;

  @override
  void initState() {
    super.initState();
    _createListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _documentController.dispose();
    _lastnameController.dispose();
    _documentFocusNode.dispose();
    _lastnameFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: buildCircularProgress(),
                )
              : _buildSearchBox(),
          //_customerFound != null
          widget.customerSelected != null
              ? Text(widget.customerSelected!, //_customerFound!
                  style: const TextStyle(fontSize: 14.0)
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CreateTextFormField(
            controller: _documentController,
            focusNode: _documentFocusNode,
            label: 'Documento',
            dataType: DataTypeEnum.identificationDocument,
            acceptEmpty: true,
            textForValidation: 'Ingrese un documento válido, sin puntos ni guiones',
            viewCharactersCount: false,
          ),
          CreateTextFormField(
            controller: _lastnameController,
            focusNode: _lastnameFocusNode,
            label: 'Apellido',
            dataType: DataTypeEnum.text,
            maxValueForValidation: 25,
            acceptEmpty: true,
            viewCharactersCount: false,
          ),
        ],
      ),
    );
  }

  //"value": es el dato a buscar (documento o apellido del cliente)
  Future<void> _updateCustomerList({
    required bool isDocument,
    required String value}) async {

    setState(() {
      _isLoading = true;
    });
    try {
      await fetchCustomerList(
        customerList: _customerList,
        searchByDocument: isDocument,
        value: value,
      );
    } catch (error) {
      return Future.error(error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Null> _showMessageConnectionError({
    required BuildContext context,
    required Object? error,
    required bool isDocument
  }) async {
    if (kDebugMode) print('_showMessageConnectionError: $error');
    FloatingMessage.show(
      context: context,
      text: "Error de conexión",
      messageTypeEnum: MessageTypeEnum.error,
      allowFlow: true,
    );
    _pushFocus(context: context, isDocument: isDocument);
  }

  void _createListeners() {
    _documentListener();
    _lastnameListener();
  }

  void _documentListener() {
    return _documentFocusNode.addListener(() async {
      // perdida de foco;
      if (!_documentFocusNode.hasFocus) {
        if (_documentController.text.trim().isNotEmpty) {
          if (!_formKey.currentState!.validate()) return;
          if (int.tryParse(_documentController.text.trim()) != null) {
            await _updateCustomerList(
                isDocument: true,
                value: _documentController.text
            ).then((value) {
              if (_customerList.isNotEmpty) _updateSelectedClient(0);
            }).onError((error, stackTrace) {
              if (error.toString().contains(HttpStatus.notFound.toString())) {
                _notFound(viewMessage: true, isDocument: true);
              } else { //InternalServerError
                _showMessageConnectionError(
                    context: context, error: error, isDocument: true);
              }
            });

          } else {
            await OpenDialog(
              context: context,
              title: 'Atención',
              content: 'Documento incorrecto',
            ).view();
            _pushFocus(context: context, isDocument: true);
          }
        }
      }
    });
  }

  void _lastnameListener() {
    _lastnameFocusNode.addListener(() async {
      // perdida de foco
      if (!_lastnameFocusNode.hasFocus) {
        if (_lastnameController.text.trim().isNotEmpty) {
          await _updateCustomerList(
            isDocument: false,
            value: _lastnameController.text
          ).then((value) {
            if (_customerList.isNotEmpty) {
              if (_customerList.length == 1) {
                _updateSelectedClient(0);
              } else {
                _clientSelection();
              }
            } else {
              _notFound(viewMessage: true, isDocument: false);
            }
          }).onError((error, stackTrace) =>
            _showMessageConnectionError(
                context: context, error: error, isDocument: false)
          );
        }
      }
    });
  }

  void _clientSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomerSelectionDialog(
          customers: _customerList,
          onSelect: (selectedIndex) {
            if (selectedIndex > -1) {
              _updateSelectedClient(selectedIndex);
            } else {
              _notFound(viewMessage: false, isDocument: false);
            }
          },
        );
      },
    );
  }

  void _updateSelectedClient(int selectedIndex) {
     /*_customerFound = '${_customerList[selectedIndex].name} '
                      '${_customerList[selectedIndex].lastname} '
                      '(${_customerList[selectedIndex].document})';
      */

    //Llama a la funcion de usuario y pasa el Customer seleccionado
    widget.onSelectedChanged(
        CustomerDTO1(
          customerId: _customerList[selectedIndex].customerId!,
          name: _customerList[selectedIndex].name,
          lastname: _customerList[selectedIndex].lastname!,
          document: _customerList[selectedIndex].document!,
          telephone: _customerList[selectedIndex].telephone!,
          addDate: _customerList[selectedIndex].addDate,
          paymentNumber: _customerList[selectedIndex].paymentNumber,
          partner: _customerList[selectedIndex].partner,
          deleted: _customerList[selectedIndex].deleted,
          notes: _customerList[selectedIndex].notes,
          partnerId: _customerList[selectedIndex].partnerId,
          dependentId: _customerList[selectedIndex].dependentId,
        )
    );

    _initializeTextFormFields();
    _nextFocus();
  }

  void _nextFocus() {
     if (widget.nextFocusNode != null) {
      setState(() {
        Future.delayed(const Duration(milliseconds: 10), () {
          FocusScope.of(context).requestFocus(widget.nextFocusNode);
        });
      });
    }
  }

  Future<void> _notFound({required bool viewMessage, required bool isDocument}) async {
    //_customerFound = null;
    widget.onSelectedChanged(null);

    if (viewMessage) {
      await OpenDialog(
        context: context,
        title: 'Atención',
        content: isDocument ? 'Documento no registrado' : 'Apellido no registrado',
      ).view();
    }
    _pushFocus(context: context, isDocument: isDocument);
  }

  void _pushFocus({required BuildContext context, required bool isDocument}) {
    setState(() {
      Future.delayed(const Duration(milliseconds: 10), (){
        FocusScope.of(context)
            .requestFocus(isDocument ? _documentFocusNode : _lastnameFocusNode); //foco vuelve al campo
      });
    });
  }

  void _initializeTextFormFields() {
    _lastnameController.value = TextEditingValue.empty;
    _documentController.value = TextEditingValue.empty;
  }


}



