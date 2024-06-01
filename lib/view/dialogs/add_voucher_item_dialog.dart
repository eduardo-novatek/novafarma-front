import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/medicine_dto.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/requests/fetch_medicine_bar_code.dart';
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
  MedicineDTO _medicine = MedicineDTO();

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
          crossAxisAlignment: CrossAxisAlignment.start,
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

            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text('Presentación: ${_voucherItem.presentation ?? ''}'),
            ),

            Text('Precio unitario: ${_voucherItem.unitPrice != null
                ? '\$${_voucherItem.unitPrice}'
                : ''}'
            ),

            CreateTextFormField(
              controller: _quantityController,
              focusNode: _quantityFocusNode,
              label: 'Cantidad',
              dataType: DataTypeEnum.number,
            ),
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
                  presentation: _voucherItem.presentation,
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
          _medicine = MedicineDTO.empty();
          await fetchMedicineBarCode(
            barCode: _barCodeController.text,
            medicine: _medicine,
          );
          if (_medicine.medicineId != null) {
              setState(() {
                _voucherItem.medicineId = _medicine.medicineId;
                _voucherItem.medicineName = _medicine.name;
                _voucherItem.presentation =
                    '${_medicine.presentation!.name} '
                    '${_medicine.presentation!.quantity} '
                    '${_medicine.presentation!.unitName}';
                _voucherItem.unitPrice = _medicine.lastSalePrice;
                _voucherItem.quantity = 0;
              });
          } else {
            floatingMessage(
                context: context,
                text: 'Artículo no encontrado',
                messageTypeEnum: MessageTypeEnum.warning
            );
            _barCodeFocusNode.requestFocus();
          }
        }
      }
    });
  }

  void _quantityListener() {
    _quantityFocusNode.addListener(() async {
      // perdida de foco
      if (!_quantityFocusNode.hasFocus && _quantityController.text.trim().isNotEmpty) {
        if (int.tryParse(_quantityController.text) != null) {
          _voucherItem.quantity = int.tryParse(_quantityController.text);
        } else {
          floatingMessage(
              context: context,
              text: 'Ingrese una cantidad válida',
              messageTypeEnum: MessageTypeEnum.warning
          );
          _quantityFocusNode.requestFocus();
        }
      }
    });
  }
}