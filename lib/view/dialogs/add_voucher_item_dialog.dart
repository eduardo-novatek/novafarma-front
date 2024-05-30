import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
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
          children: [
            CreateTextFormField(
              controller: null,

            )
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
          child: const Text("Cancelar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Aceptar"),
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              widget.onAdd(
                VoucherItemDTO(
                  medicineId: int.tryParse(articulo),
                  unitPrice: precio,
                  quantity: cantidad,
                ),
              );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
