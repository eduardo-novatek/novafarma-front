import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/tools/custom_dropdown.dart';

import '../../model/enums/data_type_enum.dart';
import '../../model/globals/publics.dart';
import '../../model/globals/tools/create_text_form_field.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {

  ThemeData themeData = ThemeData();

  String _selectedMovementType =  defaultTextFromDropdownMenu;

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
    _dateController.text = dateNow();
    _timeController.text = timeNow();
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
        verticalDirection: VerticalDirection.down,  // Se apila hacia abajo si la fila no tienen suficiente espacio
        children: [
          _buildMovementTypeBox(),
          _buildClientOrSupplierBox(),
          _buildDateTimeBox(),
        ],
      ),
    );
  }

  Widget _buildMovementTypeBox() {
    return Row(
          children: [
            const Text("Tipo: ",
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(width: 8.0,),
            CustomDropdown<String>(
              themeData: themeData,
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



  Widget _buildSupplierBox() {
    return const Expanded(
      child: Row(
        children: [
          SizedBox(width: 16.0),
          Text("Proveedor: ...",
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(width: 8.0,),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return const Placeholder();
  }

  Widget _buildClientOrSupplierBox() {
    if (_selectedMovementType != defaultTextFromDropdownMenu) {
      if (_selectedMovementType == nameMovementType(MovementTypeEnum.purchase)
            || _selectedMovementType == nameMovementType(MovementTypeEnum.returnToSupplier)) {
        return _buildSupplierBox();
      } else if (_selectedMovementType == nameMovementType(MovementTypeEnum.sale)) {
          return _buildClientBox();
      }
    }
    return const SizedBox();
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

  //String timeNow() => '${DateTime.now().hour}:${DateTime.now().minute}}';
  String timeNow() {
    final formatter = DateFormat('HH:mm');
    return formatter.format(DateTime.now());
  }

  //String dateNow() => '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
  String dateNow() {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(DateTime.now());
  }


}

