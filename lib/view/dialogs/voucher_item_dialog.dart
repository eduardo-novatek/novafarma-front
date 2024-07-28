// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novafarma_front/model/DTOs/controlled_medication_dto1.dart';
import 'package:novafarma_front/model/DTOs/customer_dto1.dart';
import 'package:novafarma_front/model/DTOs/medicine_dto1.dart';
import 'package:novafarma_front/model/DTOs/medicine_dto2.dart';
import 'package:novafarma_front/model/DTOs/supplier_dto.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/requests/add_controlled_medication.dart';
import 'package:novafarma_front/model/globals/requests/fetch_medicine_bar_code.dart';
import 'package:novafarma_front/model/globals/requests/fetch_medicine_date_authorization_sale.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/DTOs/controlled_medication_dto.dart';
import '../../model/DTOs/customer_dto.dart';
import '../../model/DTOs/medicine_dto.dart';
import '../../model/DTOs/voucher_item_dto.dart';
import '../../model/enums/movement_type_enum.dart';
import '../../model/globals/tools/message.dart';
import '../../model/globals/tools/create_text_form_field.dart';
import 'controlled_medication_dialog.dart';

class VoucherItemDialog extends StatefulWidget {
  final int customerOrSupplierId;
  final DateTime voucherDate;
  //Se especifica customer o supplier, nunca ambos.
  final CustomerDTO1? customer;
  final SupplierDTO? supplier;
  final MovementTypeEnum? movementType;
  final List<String>? barCodeList; // ID's de medicamentos agregados al voucher
  final VoucherItemDTO? modifyVoucherItem; //Si es una modificacion, el voucherItem viene cargado
  final Function(VoucherItemDTO)? onAdd;
  final Function(VoucherItemDTO)? onModify;

  const VoucherItemDialog({
    super.key,
    required this.customerOrSupplierId,
    required this.voucherDate,
    this.customer,
    this.supplier,
    this.modifyVoucherItem,
    this.movementType,
    this.barCodeList,
    this.onAdd,
    this.onModify,
  });

  @override
  State<VoucherItemDialog> createState() => _VoucherItemDialogState();
}

class _VoucherItemDialogState extends State<VoucherItemDialog> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _barCodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final FocusNode _barCodeFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();

  VoucherItemDTO _voucherItem = VoucherItemDTO.empty();

  //Carga el medicamento buscado por codigo
  MedicineDTO1 _medicine = MedicineDTO1.empty();
  //Carga el medicamento para el objeto _controlledMedication (toma los datos de _medicine)
  MedicineDTO2 _medicine2 = MedicineDTO2.empty();

  bool _focusEnabled = true;  //Foco habilitado para los TextFormField
  bool _barCodeValidated = true;
  bool _quantityValidated = true;

  ControlledMedicationDTO1? _controlledMedication = ControlledMedicationDTO1.empty();

  @override
  void initState() {
    super.initState();
    //Si es una modificacion
    if (widget.modifyVoucherItem != null) {
      _updateVoucherItem();
      _quantityController.value = TextEditingValue(
          text: '${_voucherItem.quantity}'
      );
    }
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
            height: constraints.maxHeight * 0.61,
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
                              )
                            : Text('Çódigo: ${widget.modifyVoucherItem?.barCode}'),

                          const SizedBox(height: 20),
                          _buildTable(),
                          const SizedBox(height: 5),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: CreateTextFormField(
                              controller: _quantityController,
                              focusNode: _quantityFocusNode,
                              label: 'Cantidad',
                              dataType: DataTypeEnum.number,
                              maxValueForValidation: 9999,
                              textForValidation: 'Ingrese una cantidad entre 0 y 9999',
                            ),
                          )
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
                      ElevatedButton(
                        child: const Text("Aceptar"),
                        onPressed: () {
                          Future.delayed(const Duration(milliseconds: 150), () {
                            if (!_barCodeValidated || !_quantityValidated) return;
                            if (!_formKey.currentState!.validate()) return;
                            if (widget.onAdd != null) {
                              _addVoucherItem();
                            } else if (widget.onModify != null) {
                              _modifyVoucherItem();
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
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
    widget.onModify!(
      VoucherItemDTO(
        quantity: _voucherItem.quantity,
      )
    );
    Navigator.of(context).pop();
  }

  void _addVoucherItem() {
    widget.onAdd!(
      VoucherItemDTO(
        medicineId: _voucherItem.medicineId,
        barCode: _voucherItem.barCode,
        medicineName: _voucherItem.medicineName,
        presentation: _voucherItem.presentation,
        unitPrice: _voucherItem.unitPrice,
        quantity: _voucherItem.quantity,
        currentStock: _voucherItem.currentStock,
        controlled: _voucherItem.controlled,
        controlledMedication: _controlledMedication,
      ),
    );
    _initialize(initializeCodeBar: true);
  }

  Table _buildTable() {
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
                ? _addMedicineName()
                : _modifyMedicineName(),          ],
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

  Widget _modifyMedicineName() {
    return Row (
      children: [
        _controlledIcon(),
        Text(widget.modifyVoucherItem!.medicineName!),
      ],
    );
  }

  Widget _addMedicineName() {
    return Row (
      children: [
        _controlledIcon(),
        Text(_voucherItem.medicineName ?? ''),
      ],
    );
  }

  Widget _controlledIcon() {
    return _voucherItem.controlled != null &&_voucherItem.controlled!
        ? const Tooltip(
            message: 'Medicamento controlado',
            child: Icon(Icons.copyright, color: Colors.red,)
          )
        : const SizedBox.shrink();
  }

  void _createListeners() {
    _barCodeFocusNode.addListener(_barCodeListener);
    _quantityFocusNode.addListener(_quantityListener);
  }

  void _barCodeListener() {
    if (_barCodeFocusNode.hasFocus) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
      _barCodeController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _barCodeController.text.length
      );
    } else {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    }

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
        await message(context: context, message:'El artículo ya está agregado al comprobante');
        _barCodeFocusNode.requestFocus();
        return;
      }
      _medicine = MedicineDTO1.empty();
      _medicine2 = MedicineDTO2.empty();
      await fetchMedicineBarCode(
          barCode: _barCodeController.text,
          medicine: _medicine,
      ).then((value) async {
        if (_medicine.medicineId != null) {
          _medicine2 = MedicineDTO2(
            medicineId: _medicine.medicineId,
            name: _medicine.name
          );
          if (_isSupplier() || _isAdjustmentStock() ||_medicine.currentStock! > 0) {
            (bool, DateTime?) result = (true, null);
            if (! _isSupplier() && ! _isAdjustmentStock()) {
              if (_medicine.controlled!) result = await _medicineControlledValidated();
            }
            if (result.$1) {
              _updateVoucherItem();
            } else {
              if (result.$2 != null) {
                await message(
                  context: context,
                  title: 'No autorizado',
                  message: '${_medicine.name} '
                      '${_medicine.presentation!.name} '
                      '${_medicine.presentation!.quantity} '
                      '${_medicine.presentation!.unitName}'
                      '\n\nPróxima fecha de retiro: ${dateToStr(result.$2!)}',
                );
              }
              _barCodeFocusNode.requestFocus();
            }

          } else {
            _setBarCodeValidated(false);
            await message(
                context: context,
                title: 'Sin stock',
                message:'${_medicine.name} '
                    '${_medicine.presentation!.name} '
                    '${_medicine.presentation!.quantity} '
                    '${_medicine.presentation!.unitName}'
            );
            _barCodeFocusNode.requestFocus();
          }

        /*} else {
          _setBarCodeValidated(false);
          _initialize(initializeCodeBar: false);
          await message(context: context, message: 'Artículo no encontrado');
          _barCodeFocusNode.requestFocus();

          */
        }
      }).onError((error, stackTrace) {
        _barCodeFindError(error);
      });
    });
  }

  Future<void> _barCodeFindError(Object? error) async {
    if (kDebugMode) print(error.toString());

    if (error is ErrorObject) {
    if (error.statusCode == HttpStatus.notFound) {
      _setBarCodeValidated(false);
      _initialize(initializeCodeBar: false);
      await message(context: context, message: 'Artículo no encontrado');
      _barCodeFocusNode.requestFocus();

    } else {
      _setBarCodeValidated(false);
      if (mounted) _showMessageConnectionError(context: context, isBarCode: true);
    }
  }

  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return true;  // Evento manejado
    }
    return false;  // Evento no manejado
  }

  Future<(bool, DateTime?)> _medicineControlledValidated() async {
    bool validate = true;
    DateTime? fetchDate = await fetchMedicineDateAuthorizationSale(
          customerId: widget.customerOrSupplierId,
          medicineId: _medicine.medicineId!
    ).onError((error, stackTrace) async {
      String msg = 'Error desconocido: $error';
      if (error is ErrorObject) {
        msg = _obtainMessageError(error) ?? msg;
        if (error.statusCode == HttpStatus.notFound && error.message!.contains(
            'NO POSEE UN REGISTRO DEL MEDICAMENTO CONTROLADO')) {
          //Agrega el nuevo medicamento controlado
          await _newControlledMedicationBox();
        } else {
          if (kDebugMode) print(msg);
          await message(message: msg, context: context);
        }
        validate = false;
      }
      return null;
    });

    //Si se produjo un error en fetchMedicineDateAuthorizationSale, salgo sin validar
    if (! validate) return Future.value((false, null));

    DateTime now = DateTime.now();

    //validate = primera venta || fecha <= now
    validate = true;
    if (fetchDate != null) {
      validate = (fetchDate.isBefore(now) || fetchDate.isAtSameMomentAs(now));
    }

    return Future.value((validate, fetchDate));
  }

  Future<void> _newControlledMedicationBox() async {
    _updateNewControlledMedication();
    await showDialog(
        context: context,
        barrierDismissible: false, //lo hace modal
        builder: (BuildContext context) {
          return PopScope( //Evita salida con flecha atras del navegador
              canPop: false,
              child: ControlledMedicationDialog(
                controlledMedication: _controlledMedication,
                isAdd: true,
              )
          );
        }
    ).then((value) async {
      if (! value) {  //si canceló...
        _initialize(initializeCodeBar: true);
      } else {
        ControlledMedicationDTO controlledMedication = ControlledMedicationDTO.empty();
        //Arma el json
        controlledMedication.customer = CustomerDTO(
            customerId: _controlledMedication!.customerId);
        controlledMedication.medicine = MedicineDTO(
            medicineId: _controlledMedication!.medicine?.medicineId);
        controlledMedication.frequencyDays =
            _controlledMedication!.frequencyDays;
        controlledMedication.toleranceDays =
            _controlledMedication!.toleranceDays;
        controlledMedication.lastSaleDate =
            _controlledMedication!.lastSaleDate;

        await addControlledMedication(
            controlledMedication: controlledMedication,
            context: context
        );
      }
    });
  }

  String? _obtainMessageError(ErrorObject error) {
    String? msg;

    if (error.statusCode == HttpStatus.partialContent) {
      msg = 'El medicamento no es controlado';

    } else if (error.statusCode == HttpStatus.notFound) {
      if (error.message!.contains(
          'NO POSEE UN REGISTRO DEL MEDICAMENTO CONTROLADO')) {
        msg = 'El cliente no posee un registro del medicamento controlado';
      } else if (error.message!.contains('EL CLIENTE CON ID')) {
        msg = 'El cliente no existe';
      } else if (error.message!.contains('EL MEDICAMENTO CON ID')) {
        msg = 'El medicamento no existe';
      }

    } else if (error.statusCode == HttpStatus.internalServerError) {
      msg = error.message;
    }
    return msg;
  }

  void _updateNewControlledMedication() {
    //Si _controlledMedication es null, crea el objeto vacío
    _controlledMedication ??= ControlledMedicationDTO1.empty();
    _controlledMedication?.customerId =  widget.customerOrSupplierId;
    //_controlledMedication?.medicine?.medicineId = _medicine.medicineId!;
    //_controlledMedication?.medicine?.name = _medicine.name!;
    _controlledMedication?.medicine = _medicine2;
    _controlledMedication?.customerName =
      '${widget.customer!.name} ${widget.customer!.lastname}';
    _controlledMedication?.lastSaleDate = null;
  }

  void _updateVoucherItem() {
    setState(() {
      if (widget.modifyVoucherItem == null) { //Alta?
        if (_medicine.medicineId == null) return;

        _voucherItem.medicineId = _medicine.medicineId;
        _voucherItem.barCode = _medicine.barCode;
        _voucherItem.medicineName = _medicine.name;
        _voucherItem.presentation =
        '${_medicine.presentation!.name} '
            '${_medicine.presentation!.quantity} '
            '${_medicine.presentation!.unitName}';
        _voucherItem.unitPrice = _unitPrice();
        _voucherItem.currentStock = _medicine.currentStock;
        _voucherItem.quantity = 0;
        _voucherItem.controlled = _medicine.controlled;
        _voucherItem.controlledMedication =
            _medicine.controlled! ? _controlledMedication : null;
        //
        _barCodeValidated = true;

      } else { //Modificacion
        _voucherItem.medicineId = widget.modifyVoucherItem?.medicineId;
        _voucherItem.barCode = widget.modifyVoucherItem?.barCode;
        _voucherItem.medicineName = widget.modifyVoucherItem?.medicineName;
        _voucherItem.presentation = widget.modifyVoucherItem?.presentation;
        _voucherItem.unitPrice = widget.modifyVoucherItem?.unitPrice;
        _voucherItem.currentStock = widget.modifyVoucherItem?.currentStock;
        _voucherItem.quantity = widget.modifyVoucherItem?.quantity;
        _voucherItem.controlled = widget.modifyVoucherItem?.controlled;
        _voucherItem.controlledMedication =
            _voucherItem.controlled! ? _controlledMedication : null;
      }
    });
  }

  double? _unitPrice() {
    if (widget.movementType == MovementTypeEnum.sale) {
      return _medicine.lastSalePrice!;
    } else if (_isSupplier()) {
      return _medicine.lastCostPrice!;
    }
    return null;
  }

  bool _isSupplier()  =>
    widget.movementType == MovementTypeEnum.purchase ||
    widget.movementType == MovementTypeEnum.returnToSupplier;

  bool _isAdjustmentStock() =>
    widget.movementType == MovementTypeEnum.adjustmentStock;

  void _quantityListener() {
    if (_quantityFocusNode.hasFocus) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
      _quantityController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _quantityController.text.length
      );
    } else {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    }

    Future.delayed(const Duration(milliseconds: 100), () async {
      if (!_focusEnabled ||
          _quantityFocusNode.hasFocus ||
          _quantityController.text.trim().isEmpty) {
        _setQuantityValidated(true);
        return;
      }

      double? quantity = double.tryParse(_quantityController.text);
      if (_validQuantity(quantity)) {
        quantity = _oppositeQuantity(quantity);
        if (quantity! + _voucherItem.currentStock! < 0) {
          _setQuantityValidated(false);
          await message(message: 'No hay stock suficiente', context: context);
          _quantityFocusNode.requestFocus();
        } else {
          quantity = _oppositeQuantity(quantity);
          setState(() {
            _voucherItem.quantity = quantity;
            _quantityValidated = true;
          });
        }

      } else {
        _setQuantityValidated(false);
        await message(message: 'Ingrese una cantidad válida', context: context);
        _quantityFocusNode.requestFocus();
      }
    });
  }

  double? _oppositeQuantity(double? quantity) {
     if (widget.movementType == MovementTypeEnum.sale ||
         widget.movementType == MovementTypeEnum.returnToSupplier) {
      quantity = quantity! * -1;
    }
    return quantity;
  }

  void _setBarCodeValidated(bool value) {
    if (mounted) {
      setState(() {
        _barCodeValidated = value;
      });
    }
  }

  void _setQuantityValidated(bool value) {
    if (mounted) {
      setState(() {
        _quantityValidated = value;
      });
    }
  }

  bool _validQuantity(double? quantity) {
    return quantity != null &&
      ((widget.movementType == MovementTypeEnum.adjustmentStock && quantity != 0)
        || widget.movementType != MovementTypeEnum.adjustmentStock && quantity > 0);
  }

  Future<Null> _showMessageConnectionError({
    required BuildContext context,
    required bool isBarCode,
  }) async {
    FloatingMessage.show(
      context: context,
      text: "Error de conexión",
      messageTypeEnum: MessageTypeEnum.error,
      allowFlow: true,
    );
    /*await floatingMessage(
      context: context,
      text: "Error de conexión",
      messageTypeEnum: MessageTypeEnum.error,
      allowFlow: true,
    );*/
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
      _medicine = MedicineDTO1.empty();
      _controlledMedication = null;
      _voucherItem = VoucherItemDTO.empty();
      if (initializeCodeBar) {
        _barCodeController.value = TextEditingValue.empty;
        _pushFocus(context: context, isBarCode: true);
      }
    });
  }

}