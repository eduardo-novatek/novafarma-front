import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novafarma_front/model/DTOs/customer_dto.dart';
import 'package:novafarma_front/model/DTOs/supplier_dto.dart';
import 'package:novafarma_front/model/DTOs/voucher_item_dto.dart';
import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/tools/custom_dropdown.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';
import 'package:novafarma_front/view/boxes/customer_box.dart';
import 'package:novafarma_front/view/boxes/supplier_box.dart';
import '../../model/enums/data_type_enum.dart';
import '../../model/globals/publics.dart';
import '../../model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/constants.dart' show
    defaultTextFromDropdownMenu;

import '../dialogs/voucher_item_dialog.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {

  final ThemeData _themeData = ThemeData();

  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _documentFocusNode = FocusNode();

  String _selectedMovementType = defaultTextFromDropdownMenu;
  int _selectedCustomerOrSupplierId = 0;
  CustomerDTO? _customer = CustomerDTO.empty();
  SupplierDTO? _supplier = SupplierDTO.empty();
  double _totalPriceVoucher = 0;
  late bool _isCustomer, _isSupplier;

  final List<VoucherItemDTO> _voucherItemList = [];
  final List<String> _barCodeList = []; //Para control de medicamentos ingresados al voucher

  @override
  void initState() {
    super.initState();
    _createListeners();
    _dateController.value = TextEditingValue(text: dateNow());
  }

  @override
  void dispose() {
    super.dispose();
    _documentController.dispose();
    _dateController.dispose();
    _documentFocusNode.dispose();
    _dateFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleBar(),
            _buildHead(),
            const Divider(),
            _selectedCustomerOrSupplierId  > 0
                || toMovementTypeEnum(_selectedMovementType) == MovementTypeEnum.adjustmentStock
              ? _buildBody()
              : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(8.0),
      child: const Text(
        'Comprobantes',
        style: TextStyle(
          color: Colors.white,
          fontSize: 19.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSectionTitleBar({required String sectionTitle}) {
    return Container(
      color: Colors.blue.shade100,
      padding: const EdgeInsets.all(3.0),
      child: Text(
        sectionTitle,
        style: TextStyle(
          color: Colors.blue.shade900,
          fontSize: 15.0,
        ),
        textAlign: TextAlign.center,

      ),
    );
  }

  Widget _buildHead() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMovementTypeBox(),
          _buildSupplierOrCustomerBox(),
          // ignore: avoid_print
          IconButton(onPressed: () => print(_selectedCustomerOrSupplierId), icon: const Icon(Icons.abc)),
        ],
      ),
    );
  }

  /*Widget _buildHead() {
    return FocusTraversalGroup(
      policy:  CustomOrderedTraversalPolicy(),
        child: Shortcuts(shortcuts: <LogicalKeySet, Intent> {
            LogicalKeySet(LogicalKeyboardKey.enter): const NextFocusIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>> {
            NextFocusIntent: CallbackAction<NextFocusIntent> (
              onInvoke: (NextFocusIntent intent) {
                FocusScope.of(context).nextFocus();
                return null;
              },
            ),
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMovementTypeBox(),
                _buildSupplierOrCustomerBox(),
                IconButton(onPressed: () => print(_selectedCustomerOrSupplierId), icon: Icon(Icons.abc)),
              ],
          ),
        ),
      ),
    ));
  }*/

  Widget _buildMovementTypeBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.17,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitleBar(sectionTitle: "Datos comprobante"),
          _buildDateTimeBox(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Tipo:',
                  style: TextStyle(fontSize: 16.0),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CustomDropdown<String>(
                      themeData: _themeData,
                      modelList: movementTypes,
                      model: movementTypes[0],
                      callback: (movementType) {
                        //Si cambió el tipo de comprobante
                        if (_selectedMovementType != movementType!) {
                          setState(() {
                            _selectedMovementType = movementType;
                            _isCustomer = (_selectedMovementType == nameMovementType(MovementTypeEnum.sale));
                            _isSupplier = (
                                _selectedMovementType == nameMovementType(MovementTypeEnum.purchase) ||
                                _selectedMovementType == nameMovementType(MovementTypeEnum.returnToSupplier));
                            _selectedCustomerOrSupplierId = 0;
                            _voucherItemList.clear();
                            _barCodeList.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return _selectedMovementType != defaultTextFromDropdownMenu
        ? Expanded(
            child: Column(
              children: [
                _columnsBody(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _voucherItemList.length,
                    itemBuilder: (context, index) {
                      return _buildVoucherItem(_voucherItemList[index], index);
                    },
                  ),
                ),
                _selectedMovementType != nameMovementType(MovementTypeEnum.adjustmentStock)
                    ? _boxTotalVoucher()
                    : const SizedBox.shrink(),

                const Divider(),
                _footerBody(),
              ],
            ),
          )

        : const SizedBox.shrink();
  }

  Widget _boxTotalVoucher() {
    return Column (
      children: [
        const Divider(),
        _totalsBody(),
      ],
    );
  }

  Widget _totalsBody() {
    _updateTotalVoucher();
    return Row (
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Total: \$ ',
          style: TextStyle(fontSize: 17,),),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Text(
            NumberFormat('#,##0.00', 'es_ES').format(_totalPriceVoucher),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
        ),
      ],
    );
  }

  void _updateTotalVoucher() {
    _totalPriceVoucher = 0;
    for (var voucherItemDTO in _voucherItemList) {
      _totalPriceVoucher += voucherItemDTO.unitPrice! * voucherItemDTO.quantity!;
    }
  }

  Table _columnsBody() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(0.6),
        5: FixedColumnWidth(96),
      },
      children: [
        TableRow(
          children: [
            //Icono de "medicamento controlado"
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox.shrink(),
            ),
           const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("ARTÍCULO", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("PRESENTACI\xD3N", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      _selectedMovementType != nameMovementType(MovementTypeEnum.adjustmentStock)
                        ? 'PRECIO UNITARIO'
                        : 'STOCK',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("CANTIDAD", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox.shrink(), // Celda vacía para los botones de acción
          ],
        ),
      ],
    );
  }

  Row _footerBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Agregar items',
                  style: const ButtonStyle(
                    iconSize: MaterialStatePropertyAll(40.0),
                    iconColor: MaterialStatePropertyAll(Colors.blue),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false, //lo establece modal
                      builder: (BuildContext context) {
                        return PopScope( //Evita salida con flecha atrás del navegador
                          canPop: false,
                          child: VoucherItemDialog(
                            customerOrSupplierId: _selectedCustomerOrSupplierId,
                            voucherDate: strToDate(_dateController.text)!,
                            customer: _isCustomer ? _customer : null,
                            supplier: _isSupplier ? _supplier : null,
                            movementType: toMovementTypeEnum(_selectedMovementType)!,
                            barCodeList: _barCodeList,
                            onAdd: (voucherItemDTO) {
                              setState(() {
                                _voucherItemList.add(voucherItemDTO);
                                _barCodeList.add(voucherItemDTO.barCode!);
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: const Text('Aceptar', style: TextStyle(fontSize: 17.0),),
              onPressed: () {

              },
            ),

            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 8.0),
              child: TextButton(
                child: const Text('Cancelar', style: TextStyle(fontSize: 17.0),),
                onPressed: () {

                },
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildVoucherItem(VoucherItemDTO item, int index) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(0.6),
        5: FixedColumnWidth(96),
      },
      children: [
        TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: item.controlled != null && item.controlled!
                    ? const Tooltip(
                  message: 'Medicamento controlado',
                  child: Icon(Icons.copyright, color: Colors.red),
                )
                    : const SizedBox.shrink(),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(item.medicineName ?? '<sin especificar>'),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(item.presentation ?? '<sin especificar>'),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  _selectedMovementType != nameMovementType(MovementTypeEnum.adjustmentStock)
                      ? item.unitPrice != null
                      ? NumberFormat('#,##0.00', 'es_ES').format(item.unitPrice)
                      : '0,00'
                      : item.currentStock != null
                      ? NumberFormat('#,##0.00', 'es_ES').format(item.currentStock)
                      : '0,00',
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  item.quantity != null
                      ? NumberFormat('#,##0.00', 'es_ES').format(item.quantity)
                      : '0,00',
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar item',
                      onPressed: () => _editVoucherItem(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Borrar item',
                      onPressed: () => _deleteVoucherItem(index),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _editVoucherItem(int index) {

    VoucherItemDTO modifyVoucherItem = VoucherItemDTO(
      voucherItemId: _voucherItemList[index].voucherItemId,
      medicineId: _voucherItemList[index].medicineId,
      barCode: _voucherItemList[index].barCode,
      medicineName: _voucherItemList[index].medicineName,
      presentation: _voucherItemList[index].presentation,
      currentStock: _voucherItemList[index].currentStock,
      unitPrice: _voucherItemList[index].unitPrice,
      quantity: _voucherItemList[index].quantity,
      controlled: _voucherItemList[index].controlled,
    );

    showDialog(
      context: context,
      barrierDismissible: false, //lo hace modal
      builder: (BuildContext context) {
        return PopScope( //Evita salida con flecha atras del navegador
          canPop: false,
          child: VoucherItemDialog(
            customerOrSupplierId: _selectedCustomerOrSupplierId,
            voucherDate: strToDate(_dateController.text)!,
            movementType: toMovementTypeEnum(_selectedMovementType),
            modifyVoucherItem: modifyVoucherItem,
            onModify: (modifiedVoucher) {
              setState(() {
                _voucherItemList[index].quantity = modifiedVoucher.quantity;
              });
            },
          ),
        );
      },
    );

  }

  void _deleteVoucherItem(int index) {
    setState(() {
      _voucherItemList.removeAt(index);
      _barCodeList.removeAt(index);
    });
  }

  Widget _buildSupplierOrCustomerBox() {
    if (_selectedMovementType != defaultTextFromDropdownMenu) {
      //Es Proveedor?
      if (_isSupplier){
        return Container(
          width: MediaQuery.of(context).size.width * 0.275,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitleBar(sectionTitle: "Datos proveedor"),
              SupplierBox(
                //selectedId: _selectedCustomerOrSupplierId,
                onSelectedChanged: (supplier) => setState(() {
                  if (supplier == null || supplier.supplierId == 0) {
                    _selectedCustomerOrSupplierId = 0;
                    _supplier = null;
                  } else {
                    _selectedCustomerOrSupplierId = supplier.supplierId!;
                    _updateSupplier(supplier);
                  }
                }),
              ),
            ],
          ),
        );

        //Es Cliente?
      } else if (_isCustomer) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.3,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
              width: 1.0,
            ),
          ),child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitleBar(sectionTitle: "Datos cliente"),
              CustomerBox(
                  //selectedId: _selectedCustomerOrSupplierId,
                  onSelectedChanged: (customer) => setState(() {
                    //_selectedCustomerOrSupplierId = value;
                    if (customer == null) {
                      _selectedCustomerOrSupplierId = 0;
                      _customer = null;
                    } else {
                      _selectedCustomerOrSupplierId = customer.customerId!;
                      _updateCustomer(customer);
                    }
                  })
              ),
            ],
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  void _updateSupplier(SupplierDTO s) {
    _supplier?.supplierId = s.supplierId;
    _supplier?.name = s.name;
    _supplier?.address = s.address;
    _supplier?.email = s.email;
    _supplier?.telephone1 = s.telephone1;
    _supplier?.telephone2 = s.telephone2;
    _supplier?.notes = s.notes;
  }

  void _updateCustomer(CustomerDTO c) {
    _customer?.customerId = c.customerId;
    _customer?.name = c.name;
    _customer?.lastname = c.lastname;
    _customer?.document = c.document;
    _customer?.telephone = c.telephone;
    _customer?.addDate = c.addDate;
    _customer?.paymentNumber = c.paymentNumber;
    _customer?.partner = c.partner;
    _customer?.deleted = c.deleted;
    _customer?.notes = c.notes;
    _customer?.partnerId = c.partnerId;
    _customer?.dependentId = c.dependentId;
  }

  Widget _buildDateTimeBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CreateTextFormField(
        controller: _dateController,
        focusNode: _dateFocusNode,
        label: 'Fecha',
        dataType: DataTypeEnum.date,
        initialFocus: true,
      ),
    );
  }

  String timeNow() {
    final formatter = DateFormat('HH:mm');
    return formatter.format(DateTime.now());
  }

  String dateNow() {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(DateTime.now());
  }

  void _createListeners() {
    _dateListener();
  }
  void _dateListener() {
    _dateFocusNode.addListener(() {
      // Perdida de foco
      if (! _dateFocusNode.hasFocus) {
        if (strToDate(_dateController.text) == null) {
          _dateController.value = TextEditingValue(text: dateNow());
        }
      }
    });

  }
}


/*class NextFocusIntent extends Intent {
  const NextFocusIntent();
}

class CustomOrderedTraversalPolicy extends OrderedTraversalPolicy {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    if (direction == TraversalDirection.right) {
      return true;
    }
    return super.inDirection(currentNode, direction);
  }
}*/


