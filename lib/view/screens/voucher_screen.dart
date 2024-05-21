import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/requests/fetch_supplierList.dart';
import 'package:novafarma_front/model/globals/tools/custom_dropdown.dart';
import 'package:novafarma_front/view/boxes/supplier_box.dart';

import '../../model/DTOs/supplier_dto.dart';
import '../../model/enums/data_type_enum.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/enums/request_type_enum.dart';
import '../../model/globals/publics.dart';
import '../../model/globals/requests/fetch_data_object.dart';
import '../../model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/constants.dart' show
    defaultTextFromDropdownMenu, uriSupplierFindAll;

import '../../model/globals/tools/floating_message.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {

  final ThemeData _themeData = ThemeData();

  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final FocusNode _documentFocusNode = FocusNode();
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _timeFocusNode = FocusNode();

  String _selectedMovementType = defaultTextFromDropdownMenu;

  int _selectedSupplierId = 0;
  //final ValueNotifier<int> _<selectedSupplierId = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _dateController.value = TextEditingValue(text: dateNow());
    _timeController.value = TextEditingValue(text: timeNow());
  }

  @override
  void dispose() {
    super.dispose();
    _documentController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _documentFocusNode.dispose();
    _dateFocusNode.dispose();
    _timeFocusNode.dispose();
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        verticalDirection: VerticalDirection.down,
        children: [
          _buildMovementTypeBox(),
          _buildClientOrSupplierBox(),
          _buildDateTimeBox(),
          //IconButton(onPressed: () => print(_selectedSupplierId.value), icon: Icon(Icons.abc)),
          IconButton(onPressed: () => print(_selectedSupplierId), icon: Icon(Icons.abc)),

        ],
      ),
    );
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

  Widget _buildClientBox() {
    return Expanded(
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          Expanded(
            child: CreateTextFormField(
              controller: _documentController,
              focusNode: _documentFocusNode,
              label: 'Documento del cliente',
              dataType: DataTypeEnum.identificationDocument,
              acceptEmpty: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return const SizedBox.shrink();
  }

  /*Widget _buildClientOrSupplierBox() {
    return _selectedMovementType != defaultTextFromDropdownMenu &&
        (_selectedMovementType == nameMovementType(MovementTypeEnum.purchase) ||
            _selectedMovementType == nameMovementType(MovementTypeEnum.returnToSupplier))
        ? ValueListenableBuilder<int>(
            valueListenable: _selectedSupplierId,
            builder: (context, value, child) {
              return SupplierBox(
                selectedSupplierId: value,
                onSelectedSupplierIdChanged: (value) =>
                    _selectedSupplierId.value = value,
              );
            },
          )
        : const SizedBox();
  }*/

  Widget _buildClientOrSupplierBox() {
    if (_selectedMovementType != defaultTextFromDropdownMenu) {
      if (_selectedMovementType == nameMovementType(MovementTypeEnum.purchase) ||
          _selectedMovementType == nameMovementType(MovementTypeEnum.returnToSupplier)) {
        return SupplierBox(
          selectedSupplierId: _selectedSupplierId,
          onSelectedSupplierIdChanged: (value) => setState(() {
            _selectedSupplierId = value;
          }),
        );
      } else if (_selectedMovementType == nameMovementType(MovementTypeEnum.sale)) {
        // return CustomerBox(customerList: _customerList, selectedCustomer: _selectedCustomer);
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildDateTimeBox() {
    return Expanded(
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
          const SizedBox(width: 16.0),
          Expanded(
            child: CreateTextFormField(
              controller: _timeController,
              focusNode: _timeFocusNode,
              label: 'Hora',
              dataType: DataTypeEnum.time,
            ),
          ),
        ],
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
}



/*class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {

  final ThemeData _themeData = ThemeData();
  //bool _loading = false;
  String _selectedMovementType = defaultTextFromDropdownMenu;

  int _selectedSupplierId = 0;
  //final List<SupplierDTO> _supplierList = [];

  // documento de identidad del cliente (o RUT del proveedor si se implementa)
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final FocusNode _documentFocusNode = FocusNode();
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _timeFocusNode = FocusNode();


  @override
  void initState() {
    super.initState();
    _dateController.value = TextEditingValue(text: dateNow());
    _timeController.value = TextEditingValue(text: timeNow());
  }

  @override
  void dispose() {
    super.dispose();
    _documentController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _documentFocusNode.dispose();
    _dateFocusNode.dispose();
    _timeFocusNode.dispose();
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        verticalDirection: VerticalDirection.down,
        // Se apila hacia abajo si la fila no tienen suficiente espacio
        children: [
          _buildMovementTypeBox(),
          _buildClientOrSupplierBox(),
          _buildDateTimeBox(),
          //@1
          IconButton(onPressed: () => print(_selectedSupplierId), icon: Icon(Icons.abc)),
        ],
      ),
    );
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

  Widget _buildClientBox() {
    return Expanded(
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          Expanded(
            child: CreateTextFormField(
              controller: _documentController,
              focusNode: _documentFocusNode,
              label: 'Documento del cliente',
              dataType: DataTypeEnum.identificationDocument,
              acceptEmpty: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return const SizedBox();
  }

  Widget _buildClientOrSupplierBox() {
    if (_selectedMovementType != defaultTextFromDropdownMenu) {
      if (_selectedMovementType == nameMovementType(MovementTypeEnum.purchase) ||
          _selectedMovementType == nameMovementType(MovementTypeEnum.returnToSupplier)) {
        return SupplierBox(
          selectedSupplierId: _selectedSupplierId,
          onSelectedSupplierIdChanged: (value) => _selectedSupplierId = value,
        );
      } else
      if (_selectedMovementType == nameMovementType(MovementTypeEnum.sale)) {
        //return CustomerBox(customerList: _customerList, selectedCustomer: _selectedCustomer);
      }
    }
    return const SizedBox();
  }

  void showMessageConnectionError(BuildContext context) {
    floatingMessage(
                  context: context,
                  text: "Error de conexión",
                  messageTypeEnum: MessageTypeEnum.error
    );
  }

  Widget _buildDateTimeBox() {
    return Expanded(
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
          const SizedBox(width: 16.0),
          Expanded(
            child: CreateTextFormField(
              controller: _timeController,
              focusNode: _timeFocusNode,
              label: 'Hora',
              dataType: DataTypeEnum.time,
            ),
          ),
        ],
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

}*/

