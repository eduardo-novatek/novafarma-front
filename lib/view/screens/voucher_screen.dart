import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:novafarma_front/model/DTOs/voucher_item_dto.dart';
import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/tools/custom_dropdown.dart';
import 'package:novafarma_front/view/boxes/customer_box.dart';
import 'package:novafarma_front/view/boxes/supplier_box.dart';

import '../../model/enums/data_type_enum.dart';
import '../../model/globals/publics.dart';
import '../../model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/constants.dart' show
    defaultTextFromDropdownMenu;

import '../dialogs/add_voucher_item_dialog.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {

  final ThemeData _themeData = ThemeData();

  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final FocusNode _documentFocusNode = FocusNode();
  final FocusNode _dateFocusNode = FocusNode();
  //final FocusNode _movementTypeFocusNode = FocusNode();

  String _selectedMovementType = defaultTextFromDropdownMenu;
  int _selectedCustomerOrSupplierId = 0;

  List<VoucherItemDTO> _voucherItemList = [];

  @override
  void initState() {
    super.initState();
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
            _buildBody(),
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
          fontSize: 16.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHead() {
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
              children: [
                _buildMovementTypeBox(),
                _buildSupplierOrCustomerBox(),
                _buildDateTimeBox(),
                IconButton(onPressed: () => print(_selectedCustomerOrSupplierId), icon: Icon(Icons.abc)),
              ],
          ),
        ),
      ),
    ));
  }

  Widget _buildMovementTypeBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tipo: ",
          style: TextStyle(fontSize: 16.0),
        ),
        const SizedBox(width: 8.0,),
        CustomDropdown<String>(
          themeData: _themeData,
          modelList: movementTypes,
          model: movementTypes[0],
          callback: (movementType) {
            setState(() {
              _selectedMovementType = movementType!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return _selectedMovementType != defaultTextFromDropdownMenu
        ? Expanded(
            child: Column(
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                    4: FixedColumnWidth(96),
                  },
                  children: const [
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("ARTÍCULO", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("PRESENTACI\xD3N", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("PRECIO UNITARIO", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("CANTIDAD", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        SizedBox.shrink(), // Celda vacía para los botones de acción
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _voucherItemList.length,
                    itemBuilder: (context, index) {
                      return _buildVoucherItem(_voucherItemList[index], index);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AddVoucherItemDialog(
                              onAdd: (newVoucherItemDTO) {
                                setState(() {
                                  _voucherItemList.add(newVoucherItemDTO);
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          )

        : const SizedBox.shrink();
  }

  Widget _buildVoucherItem(VoucherItemDTO item, int index) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FixedColumnWidth(96),
      },
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(item.medicineName ?? '<sin especificar>'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(item.presentation ?? '<sin especificar>'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(item.unitPrice != null ? item.unitPrice.toString() : '0'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(item.quantity != null ? item.quantity.toString() : '0'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editVoucherItem(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteVoucherItem(index),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _editVoucherItem(int index) {
    // Implementa la lógica para editar el item
  }

  void _deleteVoucherItem(int index) {
    setState(() {
      _voucherItemList.removeAt(index);
    });
  }

  Widget _buildSupplierOrCustomerBox() {
    if (_selectedMovementType != defaultTextFromDropdownMenu) {
     //Es Proveedor?
      if (_selectedMovementType == nameMovementType(MovementTypeEnum.purchase) ||
          _selectedMovementType == nameMovementType(MovementTypeEnum.returnToSupplier)){
        return SupplierBox(
          selectedId: _selectedCustomerOrSupplierId,
          onSelectedIdChanged: (value) => setState(() {
            _selectedCustomerOrSupplierId = value;
          }),
        );
        //Es Cliente?
      } else if (_selectedMovementType == nameMovementType(MovementTypeEnum.sale)) {
        return CustomerBox(
            selectedId: _selectedCustomerOrSupplierId,
            nextFocusNode: _dateFocusNode,
            onSelectedIdChanged: (value) => setState(() {
              _selectedCustomerOrSupplierId = value;
            })
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildDateTimeBox() {
    return _selectedMovementType != defaultTextFromDropdownMenu
      ? Expanded(
          child: Row(
            children: [
              const SizedBox(width: 16.0),
              Expanded(
                child: CreateTextFormField(
                  controller: _dateController,
                  focusNode: _dateFocusNode,
                  label: 'Fecha',
                  dataType: DataTypeEnum.date,
                ),
              ),
            ]
          )
        )
      : const SizedBox.shrink();
  }

  String timeNow() {
    final formatter = DateFormat('HH:mm');
    return formatter.format(DateTime.now());
  }

  String dateNow() {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(DateTime.now());
  }


}

class NextFocusIntent extends Intent {
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


}


