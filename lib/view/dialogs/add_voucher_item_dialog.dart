import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';

import '../../model/DTOs/voucher_item_dto.dart';
import '../../model/globals/tools/create_text_form_field.dart';

class AddVoucherItemDialog extends StatefulWidget {
  final Function(VoucherItemDTO) onAdd;

  const AddVoucherItemDialog({super.key, required this.onAdd});

  @override
  _AddVoucherItemDialogState createState() => _AddVoucherItemDialogState();
}

class _AddVoucherItemDialogState extends State<AddVoucherItemDialog> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _barCodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final FocusNode _barCodeFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();

  final VoucherItemDTO _voucherItem = VoucherItemDTO.empty();

  @override
  void initState() {
    super.initState();
    // definir 2 listener: para codigo y cantidad. Cada uno debe definir la pardida de foco y actualizar voucherItem.
    // en el listener del codigo, ademas hace la consulta al endpoint
    _createListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _barCodeController.dispose();
    _quantityController.dispose();

    _barCodeFocusNode.dispose();
    _quantityFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Esquinas rectas
      ),
      title: const Text("Agregar artículos"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:  CrossAxisAlignment.start,
          children: [
            CreateTextFormField(
              controller: _barCodeController,
              focusNode: _barCodeFocusNode,
              label: 'Código',
              dataType: DataTypeEnum.text,
              initialFocus: true,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text('Artículo: ${_voucherItem.medicineName ?? ''}'),
            ),

            Text('Precio unitario: ${_voucherItem.unitPrice ?? ''}'),

            CreateTextFormField(
              controller: _quantityController,
              focusNode: _quantityFocusNode,
              label: 'Cantidad',
              dataType: DataTypeEnum.number,
            ),
            /*TextFormField(
              decoration: const InputDecoration(labelText: 'Artículo'),
              onChanged: (value) {
                setState(() {
                  articulo = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un artículo';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Precio Unitario'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  precio = double.tryParse(value) ?? 0;
                });
              },
              validator: (value) {
                if (value == null || double.tryParse(value) == null) {
                  return 'Por favor ingrese un precio válido';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  cantidad = int.tryParse(value) ?? 0;
                });
              },
              validator: (value) {
                if (value == null || int.tryParse(value) == null) {
                  return 'Por favor ingrese una cantidad válida';
                }
                return null;
              },
            ),*/
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Aceptar"),
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              widget.onAdd(
                VoucherItemDTO(
                  medicineId: _voucherItem.medicineId,
                  medicineName: _voucherItem.medicineName,
                  unitPrice: _voucherItem.unitPrice,
                  quantity: _voucherItem.quantity,
                ),
              );
              Navigator.of(context).pop();
            }
          },
        ),
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _createListeners() {
    _barCodeListener();
    _quantityListener();
  }

  void _barCodeListener() {
    _barCodeFocusNode.addListener(() async {
      // perdida de foco
      if (!_barCodeFocusNode.hasFocus) {
        if (_barCodeController.text.trim().isNotEmpty) {
          await _updateCustomerList(_lastnameController.text);
          if (_customerList.isNotEmpty) {
            if (_customerList.length == 1) {
              _updateSelectedClient(0);
            } else {
              _clientSelection();
            }
          } else {
            floatingMessage(
                context: context,
                text: 'Artículo no encontrado',
                messageTypeEnum: MessageTypeEnum.warning
            );
          }
        }
      }
    });
  }

  void _quantityListener() {
    _quantityFocusNode.addListener(() async {
      // perdida de foco
      if (!_quantityFocusNode.hasFocus) {
        _voucherItem.quantity = int.tryParse(_quantityController.text);
      }
    });
  }
