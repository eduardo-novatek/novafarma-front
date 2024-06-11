import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novafarma_front/model/DTOs/medicine_dto.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/requests/fetch_medicine_bar_code.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';

import '../../model/DTOs/voucher_item_dto.dart';
import '../../model/enums/movement_type_enum.dart';
import '../../model/globals/requests/create_key_pressed.dart';
import '../../model/globals/tools/create_text_form_field.dart';

class AddVoucherItemDialog extends StatefulWidget {
  final MovementTypeEnum? movementType;
  final List<String>? barCodeList; // ID's de medicamentos agregados al voucher
  final VoucherItemDTO? modifyVoucherItem; //Si es una modificacion, el voucher viene cargado
  final Function(VoucherItemDTO)? onAdd;
  final Function(VoucherItemDTO)? onModify;

  const AddVoucherItemDialog({
    super.key,
    this.modifyVoucherItem,
    this.movementType,
    this.barCodeList,
    this.onAdd,
    this.onModify,
  });

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
  bool _focusEnabled = true;  //Foco habilitado para los TextFormField
  bool _barCodeValidated = true;
  bool _quantityValidated = true;

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
                Text(widget.modifyVoucherItem == null
                    ? 'Agregar artículos'
                    : 'Modificar artículo',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.modifyVoucherItem == null
                            ? CreateTextFormField(
                                controller: _barCodeController,
                                focusNode: _barCodeFocusNode,
                                label: 'Código',
                                dataType: DataTypeEnum.text,
                                initialFocus: true,
                                onChange: (p0) {

                                },
                              )
                            : Text('Çódigo: ${widget.modifyVoucherItem?.barCode}'),

                          const SizedBox(height: 20),
                          buildTable(),
                          const SizedBox(height: 5),

                          widget.modifyVoucherItem == null
                            ? CreateTextFormField(
                                controller: _quantityController,
                                focusNode: _quantityFocusNode,
                                label: 'Cantidad',
                                dataType: DataTypeEnum.number,
                              )
                            : _fieldQuantityForModify(),
                          ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text("Aceptar"),
                        onPressed: () {
                          //print("clic en aceptar");
                          Future.delayed(const Duration(milliseconds: 150), () {
                            if (!_barCodeValidated || !_quantityValidated) return;
                            if (_formKey.currentState?.validate() == true) {
                              if (widget.onAdd != null) {
                                //print("agregando voucher");
                                _addVoucherItem();
                              } else if (widget.onModify != null) {
                                //print("modificando voucher");
                                _modifyVoucherItem();
                              }
                            }

                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        child: const Text("Cancelar"),
                        onPressed: () {
                          setState(() {
                            _focusEnabled = false;
                          });
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

  void _modifyVoucherItem() {
    //if (await _validQuantity()) {
      widget.onModify!(
        VoucherItemDTO(
          quantity: _voucherItem.quantity,
        )
      );
      Navigator.of(context).pop();

    //} else {
    //  _quantityFocusNode.requestFocus();
    //}
  }

  void _addVoucherItem() {
    //if (await _validQuantity()) {
    widget.onAdd!(
      VoucherItemDTO(
        medicineId: _voucherItem.medicineId,
        barCode: _voucherItem.barCode,
        medicineName: _voucherItem.medicineName,
        presentation: _voucherItem.presentation,
        unitPrice: _voucherItem.unitPrice,
        quantity: _voucherItem.quantity,
        currentStock: _voucherItem.currentStock,
      ),
    );
    _initialize(initializeCodeBar: true);
      //} else {
    //  _quantityFocusNode.requestFocus();
    //}
  }

  Future<bool> _validQuantity() async {
    bool isValid = true;
    int? quantity = int.parse(_quantityController.text);
    if ((widget.movementType == MovementTypeEnum.adjustmentStock && quantity == 0)
        || widget.movementType != MovementTypeEnum.adjustmentStock && quantity < 1) {
      await OpenDialog(
      context: context,
      title: 'Atención',
      content: 'Cantidad incorrecta',
      ).view();
      isValid = false;
    }
    return Future.value(isValid);
  }

  Widget _fieldQuantityForModify(){
    _quantityController.value = TextEditingValue(
        text: '${widget.modifyVoucherItem?.quantity}'
    );
    return CreateTextFormField(
        controller: _quantityController,
        focusNode: _quantityFocusNode,
        label: 'Cantidad',
        dataType: DataTypeEnum.number,
        initialFocus: true,
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
            widget.modifyVoucherItem == null
                ? Text(_voucherItem.medicineName ?? '')
                : Text(widget.modifyVoucherItem!.medicineName!),          ],
        ),
        const TableRow(
          children: [
            SizedBox(height: 10),
            SizedBox(height: 10),
          ],
        ),
        TableRow(
          children: [
            const Text('Presentación:'),
            widget.modifyVoucherItem == null
              ? Text(_voucherItem.presentation ?? '')
              : Text(widget.modifyVoucherItem!.presentation!),
          ],
        ),
        const TableRow(
          children: [
            SizedBox(height: 10),
            SizedBox(height: 10),
          ],
        ),
        widget.movementType != MovementTypeEnum.adjustmentStock
          ? TableRow(
              children: [
                const Text('Precio unitario:'),
                widget.modifyVoucherItem == null
                  ? Text(_voucherItem.unitPrice != null
                        ? '\$ ${_voucherItem.unitPrice}'
                        : '')
                  : Text(widget.modifyVoucherItem!.unitPrice != null
                        ? '\$${widget.modifyVoucherItem!.unitPrice!}'
                        : ''
                    ),
              ],
            )
          : const TableRow(
            children: [
              SizedBox.shrink(),
              SizedBox.shrink(),
            ],
          ),
        const TableRow(
          children: [
            SizedBox(height: 10),
            SizedBox(height: 10),
          ],
        ),
        TableRow(
          children: [
            const Text('Stock:'),
            widget.modifyVoucherItem == null
              ? Text(_voucherItem.currentStock != null
                  ? '${_voucherItem.currentStock}'
                  : '')
              : Text('${widget.modifyVoucherItem!.currentStock!}'),
          ],
        ),
      ],
    );
  }

  void _createListeners() {
    _barCodeFocusNode.addListener(_barCodeListener);
    _quantityFocusNode.addListener(_quantityListener);
  }

  void _barCodeListener() {
    if (isEscape()) return;
    //Da tiempo a ejecutar evento onChange de los botones del Dialog
    Future.delayed(const Duration(milliseconds: 100), () async {
      if (!_focusEnabled || _barCodeFocusNode.hasFocus) {
        _setBarCodeValidated(true);
        return;
      }
      if (_barCodeController.text.trim().isEmpty) {
        _barCodeFocusNode.requestFocus();
        _setBarCodeValidated(true);
        return;
      }
      if (widget.barCodeList!.contains(_barCodeController.text)) {
        _setBarCodeValidated(false);
        await OpenDialog(
            context: context,
            title: 'Atención',
            content: 'El artículo ya está agregado al comprobante',
        ).view();
        _barCodeFocusNode.requestFocus();
        return;
      }
      _medicine = MedicineDTO.empty();
      await fetchMedicineBarCode(
          barCode: _barCodeController.text,
          medicine: _medicine,
      ).then((value) async {
        if (_medicine.medicineId != null) {
          if (_isSupplier() ||
              widget.movementType == MovementTypeEnum.adjustmentStock ||
              _medicine.currentStock! > 0) {
            setState(() {
              _voucherItem.medicineId = _medicine.medicineId;
              _voucherItem.barCode = _medicine.barCode;
              _voucherItem.medicineName = _medicine.name;
              _voucherItem.presentation =
              '${_medicine.presentation!.name} '
                  '${_medicine.presentation!.quantity} '
                  '${_medicine.presentation!.unitName}';
              _voucherItem.unitPrice = unitPrice();
              _voucherItem.currentStock = _medicine.currentStock;
              _voucherItem.quantity = 0;
              //
              _barCodeValidated = true;
            });

          } else {
            _setBarCodeValidated(false);
            await OpenDialog(
              context: context,
              title: 'Sin stock',
              content: '${_medicine.name} '
                  '${_medicine.presentation!.name} '
                  '${_medicine.presentation!.quantity} '
                  '${_medicine.presentation!.unitName}',
            ).view();
            _barCodeFocusNode.requestFocus();
          }
        } else {
          _setBarCodeValidated(false);
          _initialize(initializeCodeBar: false);
          await OpenDialog(
            context: context,
            title: 'Atención',
            content: 'Artículo no encontrado',
          ).view();
          _barCodeFocusNode.requestFocus();
        }
      }).onError((error, stackTrace) {
        if (kDebugMode) print('Error!!: $error');
        _setBarCodeValidated(false);
        if (mounted) _showMessageConnectionError(context: context, isBarCode: true);
      });
    });
  }

  double? unitPrice() {
    if (widget.movementType == MovementTypeEnum.sale) {
      return _medicine.lastSalePrice;
    } else if (_isSupplier()) {
      return _medicine.lastCostPrice;
    }
    return null;
  }

  bool _isSupplier() {
    return widget.movementType == MovementTypeEnum.purchase ||
      widget.movementType == MovementTypeEnum.returnToSupplier;
  }

  void _quantityListener() {
    Future.delayed(const Duration(milliseconds: 100), () async {
      if (!_focusEnabled ||
          _quantityFocusNode.hasFocus ||
          _quantityController.text.trim().isEmpty) {
        _setQuantityValidated(true);
        return;
      }

      int? quantity = int.tryParse(_quantityController.text);
      if (_validQuantity1(quantity)) {
        if (widget.movementType == MovementTypeEnum.sale
            && quantity! > _voucherItem.currentStock!) {
          _setQuantityValidated(false);
          await OpenDialog(
            context: context,
            title: 'Atención',
            content: 'No hay stock suficiente',
          ).view();
          _quantityFocusNode.requestFocus();

        } else {
          print("actualizando _quantityValidated");
          setState(() {
            _voucherItem.quantity = quantity;
            _quantityValidated = true;
          });
        }

      } else {
        _setQuantityValidated(false);
        await OpenDialog(
          context: context,
          title: 'Atención',
          content: 'Ingrese una cantidad válida',
        ).view();
        _quantityFocusNode.requestFocus();
      }
    });
  }

  void _setBarCodeValidated(bool value) {
    return setState(() {
      _barCodeValidated = value;
    });
  }

  void _setQuantityValidated(bool value) {
    return setState(() {
      _quantityValidated = value;
    });
  }

  bool _validQuantity1(int? quantity) {
    return quantity != null &&
      ((widget.movementType == MovementTypeEnum.adjustmentStock && quantity != 0)
        || widget.movementType != MovementTypeEnum.adjustmentStock && quantity > 0);
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