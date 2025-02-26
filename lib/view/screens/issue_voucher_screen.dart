import 'dart:core';
import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novafarma_front/model/DTOs/customer_dto1.dart';
import 'package:novafarma_front/model/DTOs/medicine_dto.dart';
import 'package:novafarma_front/model/DTOs/supplier_dto.dart';
import 'package:novafarma_front/model/DTOs/voucher_item_dto.dart';
import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart' show
    defaultFirstOption, uriVoucherAdd;
import 'package:novafarma_front/model/globals/handleError.dart';
import 'package:novafarma_front/model/globals/tools/custom_dropdown.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';
import 'package:novafarma_front/model/objects/error_object.dart';
import 'package:novafarma_front/view/boxes/customer_box.dart';
import 'package:novafarma_front/view/boxes/supplier_box.dart';

import '../../model/DTOs/customer_dto.dart';
import '../../model/DTOs/supplier_dto_1.dart';
import '../../model/DTOs/user_dto_1.dart';
import '../../model/DTOs/voucher_dto.dart';
import '../../model/DTOs/voucher_item_dto_1.dart';
import '../../model/enums/data_type_enum.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/enums/request_type_enum.dart';
import '../../model/globals/publics.dart';
import '../../model/globals/tools/custom_text_form_field.dart';
import '../../model/globals/tools/fetch_data_object.dart';
import '../../model/globals/tools/floating_message.dart';
import '../dialogs/voucher_item_dialog.dart';

class IssueVoucherScreen extends StatefulWidget {
  final ValueChanged<bool>? onBlockedStateChange;

  const IssueVoucherScreen({super.key, this.onBlockedStateChange});

  @override
  State<IssueVoucherScreen> createState() => _IssueVoucherScreenState();
}

class _IssueVoucherScreenState extends State<IssueVoucherScreen> {

  final ThemeData _themeData = ThemeData();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final FocusNode _dateFocusNode = FocusNode();

  String _selectedMovementType = defaultFirstOption;
  int _selectedCustomerOrSupplierId = 0; //id del Customer o Supplier seleccionado
  String? _customerSelected; //'Nombre Apellido (documento)' del Customer seleccionado
  CustomerDTO1? _customer;
  SupplierDTO? _supplier;
  late bool _isCustomer, _isSupplier;
  bool _isSaving = false;
  double _totalPriceVoucher = 0;

  final List<VoucherItemDTO> _voucherItemList = [];
  final List<String> _barCodeList = []; //Para control de medicamentos ingresados al voucher

  final List<String> _movementTypes = [
    defaultFirstOption,
    nameMovementType(MovementTypeEnum.purchase),
    nameMovementType(MovementTypeEnum.sale),
    nameMovementType(MovementTypeEnum.returnToSupplier),
    nameMovementType(MovementTypeEnum.adjustmentStock),
  ];

  @override
  void initState() {
    super.initState();
    _createListeners();
    _dateController.value = TextEditingValue(text: dateNow());
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    _notesController.dispose();
    _dateFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _isSaving,
          child: Padding(
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
          ),
        ),
        if (_isSaving)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ]
    );
  }

  Widget _buildTitleBar() {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(8.0),
      child: const Text(
        'Emisión de comprobantes',
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
          //IconButton(onPressed: () => print(_selectedCustomerOrSupplierId), icon: const Icon(Icons.abc)),
        ],
      ),
    );
  }

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
                      optionList: _movementTypes,
                      selectedOption: _selectedMovementType, //movementTypes[0],
                      isSelected: true,
                      callback: (movementType) {
                        //Si cambió el tipo de comprobante
                        if (_selectedMovementType != movementType!) {
                          setState(() {
                            _selectedMovementType = movementType;
                            _isCustomer = (_selectedMovementType == nameMovementType(MovementTypeEnum.sale));
                            _isSupplier = (
                                _selectedMovementType == nameMovementType(MovementTypeEnum.purchase) ||
                                    _selectedMovementType == nameMovementType(MovementTypeEnum.returnToSupplier));
                            _initializeVoucher();
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
    return _selectedMovementType != defaultFirstOption
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

  /*Widget _notesBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 100.0, top: 8.0, right: 100.0, bottom: 8.0),
      child: CreateTextFormField(
        controller: _notesController,
        label: 'Notas',
        dataType: DataTypeEnum.text,
        acceptEmpty: true,
        validate: true,
        viewCharactersCount: true,
        isUnderline: false,
        maxLines: 2,
        maxValueForValidation: 100,
      ),
    );
  }*/

  Table _columnsBody() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.2),  //(C)
        1: FlexColumnWidth(2),    // Articulo
        2: FlexColumnWidth(1),    // Presentacion
        3: FlexColumnWidth(1),    // Precio unitario
        4: FlexColumnWidth(0.6),  // Cantidad
        5: FixedColumnWidth(96),  //botones Editar y Eliminar
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
                    iconSize: WidgetStatePropertyAll(40.0),
                    iconColor: WidgetStatePropertyAll(Colors.blue),
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
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                    icon: const Icon(Icons.note_add),
                    tooltip: _notesController.text.trim().isEmpty
                      ? 'Agregar notas' : 'Modificar notas',
                    style: const ButtonStyle(
                      iconSize: WidgetStatePropertyAll(20.0),
                      iconColor: WidgetStatePropertyAll(Colors.blue),
                    ),
                    onPressed: () {
                      _showNotes();
                    }
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: _voucherItemList.isEmpty ? null : () async {
                try {
                  int option = await OpenDialog(
                      context: context,
                      title: 'Confirmar',
                      content: '¿Confirma el comprobante?',
                      textButton1: 'Si',
                      textButton2: 'No'
                  ).view();
                  if (option == 1) {
                    await _saveVoucher();
                  }
                } catch(e) {
                  if (kDebugMode) print(e);
                  if (mounted) if (mounted) handleError(error: e, context: context);
                }
              },
              child: const Text('Aceptar', style: TextStyle(fontSize: 17.0),),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 8.0),
              child: ElevatedButton(
                child: const Text('Cancelar', style: TextStyle(fontSize: 17.0),),
                onPressed: () async {
                  int option = await OpenDialog(
                    title: 'Cancelar',
                    content: '¿Cancelar el comprobante?',
                    textButton1: 'Si',
                    textButton2: 'No',
                    context: context
                  ).view();
                  if (option == 1) _initializeVoucher();
                }
              ),
            ),
          ],
        )
      ],
    );
  }

  Future<void> _saveVoucher() async {
    setState(() {
      _changeStateSaved(true);
    });
    try {
      _validVoucher();
      await fetchDataObject<VoucherDTO>(
          uri: uriVoucherAdd,
          classObject: VoucherDTO.empty(),
          requestType: RequestTypeEnum.post,
          body: _createVoucher(),
      ).then((newVoucherId) async {
        setState(() {
          _changeStateSaved(false);
        });
        if (kDebugMode) print('Comprobante agregado con éxito (id=${newVoucherId[0]})');
        FloatingMessage.show(
            context: context,
            text: 'Comprobante guardado con éxito',
            messageTypeEnum: MessageTypeEnum.info
        );
        _initializeVoucher();
      });
    } catch (e) {
      setState(() {
        _changeStateSaved(false);
      });
      if (e is ErrorObject && mounted) {
        if (mounted) handleError(error: e, context: context);
      } else {
        throw Exception(e);
      }
    }
  }

  void _validVoucher() {
    if (_totalPriceVoucher > 999999.99) {
      throw ErrorObject(
        statusCode: HttpStatus.conflict,
        message: 'El importe del comprobante excede el máximo permitido de 999999.99',
      );
    }
  }

  void _changeStateSaved(bool isSaving) {
    _isSaving = isSaving;
    widget.onBlockedStateChange!(isSaving);
  }

  VoucherDTO _createVoucher() {
    return VoucherDTO(
      movementType: toMovementTypeEnum(_selectedMovementType)?.index,
      user: UserDTO1(userId: userLogged!.userId),
      customer: _customer != null
        ? CustomerDTO(customerId: _customer!.customerId)
        : null,
      supplier: _supplier != null
        ? SupplierDTO1(supplierId: _supplier!.supplierId)
        : null,
      dateTime:  strToDateTime('${_dateController.text} ${timeNow()}'),
      notes: _notesController.text,
      total:_totalPriceVoucher,
      voucherItemList: _getVoucherItems()
    );
  }

  List<VoucherItemDTO1> _getVoucherItems() {
    List<VoucherItemDTO1> voucherItems = [];
    for(VoucherItemDTO voucherItem in _voucherItemList) {
      voucherItems.add(VoucherItemDTO1(
        medicine: MedicineDTO(medicineId: voucherItem.medicineId),
        quantity: voucherItem.quantity,
        unitPrice: voucherItem.unitPrice
      ));
    }
    return voucherItems;
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
            customer: _isCustomer ? _customer : null,
            supplier: _isSupplier ? _supplier : null,
            voucherDate: strToDate(_dateController.text)!,
            movementType: toMovementTypeEnum(_selectedMovementType),
            modifyVoucherItem: modifyVoucherItem,
            onModify: (modifiedVoucher) {
              setState(() {
                _voucherItemList[index].unitPrice = modifiedVoucher.unitPrice;
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
    if (_selectedMovementType != defaultFirstOption) {
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
                selectFirst: _selectedCustomerOrSupplierId == 0,
                onSelectedChanged: (supplier) => setState(() {
                  if (supplier == null || supplier.supplierId == 0) {
                    _selectedCustomerOrSupplierId = 0;
                    _supplier = null;
                  } else {
                    _selectedCustomerOrSupplierId = supplier.supplierId!;
                    _updateSupplier(supplier);
                  }
                  _notesController.clear();
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
                customerSelected: _customerSelected,
                onSelectedChanged: (customer) => setState(() {
                  if (customer != null) {
                    _initializeVoucher();
                    _selectedCustomerOrSupplierId = customer.customerId!;
                    _customerSelected =
                      '${customer.lastname}, ${customer.name} (${customer.document})';
                    _updateCustomer(customer);
                    //_notesController.clear();
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
    _supplier = SupplierDTO.empty();
    _supplier?.supplierId = s.supplierId;
    _supplier?.name = s.name;
    _supplier?.address = s.address;
    _supplier?.email = s.email;
    _supplier?.telephone1 = s.telephone1;
    _supplier?.telephone2 = s.telephone2;
    _supplier?.notes = s.notes;
  }

  void _updateCustomer(CustomerDTO1 c) {
    _customer = CustomerDTO1.empty();
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
      child: CustomTextFormField(
        controller: _dateController,
        focusNode: _dateFocusNode,
        label: 'Fecha',
        dataType: DataTypeEnum.date,
        initialFocus: true,
      ),
    );
  }

  void _createListeners() {
    _dateListener();
  }
  void _dateListener() {
    _dateFocusNode.addListener(() {
      //Recibe foco
      if (_dateFocusNode.hasFocus) {
        _dateController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _dateController.text.length,
        );
        // Pierde foco
      } else if (! _dateFocusNode.hasFocus) {
        if (strToDate(_dateController.text) == null) {
          _dateController.value = TextEditingValue(text: dateNow());
        }
      }
    });
  }

  void _initializeVoucher() {
    setState(() {
      _selectedCustomerOrSupplierId = 0;
      _totalPriceVoucher = 0;
      _customerSelected = null;
      _customer = null;
      _supplier = null;
      _voucherItemList.clear();
      _barCodeList.clear();
      _notesController.clear();
    });
  }

  void _showNotes() {
    showDialog(
      barrierDismissible: false, //lo hace modal
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, //evita salida con flecha atras del navegador
          child: AlertDialog(
            title: const Text('Notas'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              child: CustomTextFormField(
                controller: _notesController,
                label: '',
                dataType: DataTypeEnum.text,
                acceptEmpty: true ,
                maxValueForValidation: 100,
                maxLines: 4,
                viewCharactersCount: true,
                initialFocus: true,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  setState(() {
                    _notesController.value = TextEditingValue(
                        text: _notesController.text.trim()
                    );
                  });
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Eliminar'),
                onPressed: () async {
                  setState(() {
                    _notesController.value = TextEditingValue(
                        text: _notesController.text.trim()
                    );
                  });
                  if (_notesController.text.isNotEmpty) {
                    int option = await OpenDialog(
                        context: context,
                        title: 'Confirmar',
                        content: '¿Eliminar la nota?',
                        textButton1: 'Si',
                        textButton2: 'No'
                    ).view();
                    if (option == 1) {
                      setState(() {
                        _notesController.clear();
                      });
                    }
                  }
                  if (context.mounted) {Navigator.of(context).pop();}
                },
              ),
            ],
          ),
        );
      },
    );
  }

}