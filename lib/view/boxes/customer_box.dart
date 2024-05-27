import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/globals/build_circular_progress.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';

import '../../model/DTOs/customer_dto.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/requests/fetch_customer_list.dart';
import '../../model/globals/tools/custom_dropdown.dart';
import '../../model/globals/constants.dart' show defaultTextFromDropdownMenu;
import '../../model/globals/tools/floating_message.dart';
import '../dialogs/customer_selection_dialog.dart';

class CustomerBox extends StatefulWidget {
  int selectedId;
  final FocusNode? nextFocusNode; // Proximo textFormField para dar el foco
  //final FocusNode? previousFocusNode; // Anterior textFormField para dar el foco
  final ValueChanged<int> onSelectedIdChanged;
  final ValueChanged<bool>? onRefreshButtonChange;

  CustomerBox({
    super.key,
    this.onRefreshButtonChange,
    this.nextFocusNode,
    //this.previousFocusNode,
    required this.selectedId,
    required this.onSelectedIdChanged,
  });

  @override
  CustomerBoxState createState() => CustomerBoxState();
}

class CustomerBoxState extends State<CustomerBox> {

  final List<CustomerDTO> _customerList = [];

  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();

  final FocusNode _documentFocusNode = FocusNode();
  final FocusNode _lastnameFocusNode = FocusNode();

  bool _isLoading = false;

  //guarda los datos del cliente encontrado ("JUAN PEREZ (12345678)")
  String? _customerFound;

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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoading
                ? buildCircularProgress()
                : _buildSearchBox(),
            _customerFound != null
                ? Text(_customerFound!,
                    style: const TextStyle(fontSize: 16.0)
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CreateTextFormField(
            controller: _documentController,
            focusNode: _documentFocusNode,
           // nextNode: widget.nextFocusNode,
           // previousNode: widget.previousFocusNode,
            label: 'Documento',
            dataType: DataTypeEnum.identificationDocument,
            acceptEmpty: true,
            viewCharactersCount: false,
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: CreateTextFormField(
            controller: _lastnameController,
            focusNode: _lastnameFocusNode,
            //nextNode: widget.nextFocusNode,
            //previousNode: widget.previousFocusNode,
            label: 'Apellido',
            dataType: DataTypeEnum.text,
            maxValueForValidation: 25,
            acceptEmpty: true,
            viewCharactersCount: false,
          ),
        ),
      ],
    );
  }

  Future<void> _updateCustomerList(String value) async {
    bool isDocument = int.tryParse(value) != null;

    setState(() {
      _isLoading = true;
    });
    try {
      //Busca por documento o po apellido.
      //Por documento, se devuelve la lista solo con el cliente encontrado (sin "seleccione...")
      //Por apellido, se devuelve la lista con las coincidencias (con "seleccione...")
      await fetchCustomerList(
        customerList: _customerList,
        searchByDocument: isDocument,
        value: value,
      ).then((value) {
          if (! isDocument) {
            _customerList.insert(
              0,
              CustomerDTO(
                isFirst: true,
                name: defaultTextFromDropdownMenu,
                customerId: 0,
              ),
            );
          }
          widget.onSelectedIdChanged(0);
        });
    } catch (error) {
      _showMessageConnectionError(context);
    } finally {
      if (_customerList.isEmpty && !isDocument) {
        _customerList.add(
          CustomerDTO(
            isFirst: true,
            name: defaultTextFromDropdownMenu,
            customerId: 0,
          ),
        );
        widget.onSelectedIdChanged(0);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  /*CustomDropdown<CustomerDTO> _buildCustomDropdown() {
    return CustomDropdown<CustomerDTO>(
      themeData: ThemeData(),
      modelList: _customerList,
      model: _customerList.isNotEmpty ? _customerList[0] : null,
      callback: (customer) {
        setState(() {
          widget.onSelectedIdChanged(customer!.customerId!);
        });
      },
    );
  }*/

  void _showMessageConnectionError(BuildContext context) {
    floatingMessage(
      context: context,
      text: "Error de conexión",
      messageTypeEnum: MessageTypeEnum.error,
    );
  }

  void _createListeners() {
    _documentListener();
    _lastnameListener();
  }

  void _lastnameListener() {
    _lastnameFocusNode.addListener(() async {
      // perdida de foco
      if (!_lastnameFocusNode.hasFocus) {
        if (_lastnameController.text.trim().isNotEmpty) {
          await _updateCustomerList(_lastnameController.text);
          if (_customerList.length > 1) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomerSelectionDialog(
                  customers: _customerList,
                  onSelect: (selectedIndex) {
                    if (selectedIndex > -1) {
                      _customerFound =
                      '${_customerList[selectedIndex].name} '
                          '${_customerList[selectedIndex].lastname} '
                          '(${_customerList[selectedIndex].document})';

                      //Actualiza el id seleccionado y la funcion de usuario actualiza el valor
                      widget.selectedId = _customerList[selectedIndex].customerId!;
                      widget.onSelectedIdChanged(widget.selectedId);
                      nextFocus();

                    } else {
                      _customerFound = null;
                      widget.selectedId = 0;

                      Future.delayed(Duration(milliseconds: 10), () {
                        FocusScope.of(context).requestFocus(_lastnameFocusNode);
                      });
                    }
                  },
                );
              },
            );

          } else {
            notFound(isDocument: false);
          }
        }
      }
    });
  }

  void _documentListener() {
    return _documentFocusNode.addListener(() async {
      // perdida de foco;
      if (!_documentFocusNode.hasFocus) {
        if (_documentController.text.trim().isNotEmpty) {
          await _updateCustomerList(_documentController.text);
          if (_customerList.length == 1) {
            _customerFound =
                '${_customerList[0].name} '
                '${_customerList[0].lastname} '
                '(${_customerList[0].document})';

            //Actualiza el id seleccionado y la funcion de usuario actualiza el valor
            widget.selectedId = _customerList[0].customerId!;
            widget.onSelectedIdChanged(widget.selectedId);

            nextFocus();

          } else {
            notFound(isDocument: true);
          }
        }
      }
    });
  }

  void nextFocus() {
     if (widget.nextFocusNode != null) {
      setState(() {
        Future.delayed(const Duration(milliseconds: 10), () {
          FocusScope.of(context).requestFocus(widget.nextFocusNode);
        });
      });
    }
  }

  void notFound({required bool isDocument}) {
    _customerFound = null;
    widget.selectedId = 0;
    floatingMessage(
        context: context,
        text: isDocument ? 'Cédula no registrada' : 'Apellido no registrado',
        messageTypeEnum: MessageTypeEnum.warning
    );
    setState(() {
      Future.delayed(const Duration(milliseconds: 10), (){
        FocusScope.of(context)
            .requestFocus(isDocument ? _documentFocusNode : _lastnameFocusNode); //foco vuelve al campo
      });
    });
  }



}



