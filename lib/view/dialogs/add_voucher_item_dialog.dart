import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/medicine_dto.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/requests/fetch_medicine_bar_code.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';

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

  VoucherItemDTO _voucherItem = VoucherItemDTO.empty();
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
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Esquinas rectas
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth * 0.4, // 40% del ancho disponible
            height: constraints.maxHeight * 0.55, // 60% del alto disponible
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
            child: Column(
              children: [
                const Text(
                  "Agregar artículos",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CreateTextFormField(
                            controller: _barCodeController,
                            focusNode: _barCodeFocusNode,
                            label: 'Código',
                            dataType: DataTypeEnum.text,
                            initialFocus: true,
                          ),
                          const SizedBox(height: 20),
                          buildTable(),
                          const SizedBox(height: 5),
                          CreateTextFormField(
                            controller: _quantityController,
                            focusNode: _quantityFocusNode,
                            label: 'Cantidad',
                            dataType: DataTypeEnum.number,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0), // Espacio ajustado
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                            _initialize(initializeCodeBar: true);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        child: const Text("Cancelar"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Table buildTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            const Text('Artículo:'),
            Text(_voucherItem.medicineName ?? ''),
          ],
        ),
        const TableRow(
          children: [
            SizedBox(height: 20),
            SizedBox(height: 20),
          ],
        ),
        TableRow(
          children: [
            const Text('Presentación:'),
            Text(_voucherItem.presentation ?? ''),
          ],
        ),
        const TableRow(
          children: [
            SizedBox(height: 20),
            SizedBox(height: 20),
          ],
        ),
        TableRow(
          children: [
            const Text('Precio unitario:'),
            Text(_voucherItem.unitPrice != null
                ? '\$${_voucherItem.unitPrice}'
                : ''
            ),
          ],
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
      if (_barCodeFocusNode.hasFocus) return;  // Si recibe el foco, sale
      if (_barCodeController.text.trim().isEmpty) return;

      _medicine = MedicineDTO.empty();
      await fetchMedicineBarCode(
        barCode: _barCodeController.text,
        medicine: _medicine,

      ).then((value) async {
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
          /*await floatingMessage(
            context: context,
            text: 'Artículo no encontrado',
            messageTypeEnum: MessageTypeEnum.warning
        );*/
          _initialize(initializeCodeBar: false);
          await OpenDialog(
              context: context,
              title: 'Atención',
              content: 'Artículo no encontrado',
          ).view();
          _barCodeFocusNode.requestFocus();
        }

      }).onError((error, stackTrace) =>
          _showMessageConnectionError(context: context, isBarCode: true)
      );
    });
  }

  void _quantityListener() {
    _quantityFocusNode.addListener(() async {
      // perdida de foco
      if (!_quantityFocusNode.hasFocus && _quantityController.text.trim().isNotEmpty) {
        if (int.tryParse(_quantityController.text) != null) {
          _voucherItem.quantity = int.tryParse(_quantityController.text);
        } else {
          /*floatingMessage(
              context: context,
              text: 'Ingrese una cantidad válida',
              messageTypeEnum: MessageTypeEnum.warning
          );*/
          await OpenDialog(
            context: context,
            title: 'Atención',
            content: 'Ingrese una cantidad válida',
          ).view();
          _quantityFocusNode.requestFocus();
        }
      }
    });
  }

  Future<Null> _showMessageConnectionError({
    required BuildContext context,
    required bool isBarCode,
  }) async {
    await floatingMessage(
      context: context,
      text: "Error de conexión",
      messageTypeEnum: MessageTypeEnum.error,
      allowFlow: true,
    );
    if (context.mounted) _pushFocus(context: context, isBarCode: isBarCode);
  }

  void _pushFocus({required BuildContext context, required bool isBarCode}) {
    setState(() {
      Future.delayed(const Duration(milliseconds: 10), (){
        FocusScope.of(context)
            .requestFocus(isBarCode ? _barCodeFocusNode : _quantityFocusNode); //foco vuelve al campo
      });
    });
  }

  void _initialize({required bool initializeCodeBar}) {
    setState(() {
      _quantityController.value = TextEditingValue.empty;
      _voucherItem = VoucherItemDTO.empty();
      if (initializeCodeBar) {
        _barCodeController.value = TextEditingValue.empty;
        _pushFocus(context: context, isBarCode: true);
      }

    });
  }

}