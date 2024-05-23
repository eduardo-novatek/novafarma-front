import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/globals/build_circular_progress.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';

import '../../model/DTOs/customer_dto.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/requests/fetch_customer_list.dart';
import '../../model/globals/tools/custom_dropdown.dart';
import '../../model/globals/constants.dart' show defaultTextFromDropdownMenu;
import '../../model/globals/tools/floating_message.dart';

class CustomerBox extends StatefulWidget {
  final int selectedId;
  final ValueChanged<int> onSelectedIdChanged;
  final ValueChanged<bool>? onRefreshButtonChange;

  const CustomerBox({
    super.key,
    this.onRefreshButtonChange,
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
  //Si no existe: "PEPE (cliente no registrado)"
  String? _customerFound;

  @override
  void initState() {
    super.initState();
    _updateCustomerList();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildRefreshButton(),
                const Text('Cliente:',
                     style: TextStyle(fontSize: 16.0)
                ),
              ],
            ),
            _isLoading
                ? buildCircularProgress()
                : _buildSearchBox(),
            _customerFound != null
                ? Text(_customerFound!)
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
      await fetchCustomerList(
          customerList: _customerList,
          searchByDocument: isDocument)
          .then((value) {
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

  IconButton _buildRefreshButton() {
    return IconButton(
      onPressed: () async {
        if (!_isLoading) {
          // llama al callback: esta haciendo el refresh...
          if (widget.onRefreshButtonChange != null) widget.onRefreshButtonChange!(true);
          await _updateCustomerList();
          // llama al callback: no está haciendo el refresh...
          if (widget.onRefreshButtonChange != null) widget.onRefreshButtonChange!(false);
        }
      },
      icon: const Icon(
        Icons.refresh_rounded,
        color: Colors.blue,
        size: 16.0,
      ),
    );
  }

  CustomDropdown<CustomerDTO> _buildCustomDropdown() {
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
  }

  void _showMessageConnectionError(BuildContext context) {
    floatingMessage(
      context: context,
      text: "Error de conexión",
      messageTypeEnum: MessageTypeEnum.error,
    );
  }

  void _createListeners() {
    _documentFocusNode.addListener(() {
      // perdida de foco
      if (!_documentFocusNode.hasFocus) {

      }

    });

    _lastnameFocusNode.addListener(() {
      // perdida de foco
      if (!_documentFocusNode.hasFocus) {

      }

    });


  }



}



