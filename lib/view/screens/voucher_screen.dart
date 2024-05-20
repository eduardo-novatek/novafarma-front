import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/tools/custom_dropdown.dart';

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
  bool _loading = false;
  String _selectedMovementType = defaultTextFromDropdownMenu;

  Map<String, dynamic> _selectedSupplier = {
    'id': 0,
    'name': '',
  };

  // documento de identidad del cliente (o RUT del proveedor si se implementa)
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final FocusNode _documentFocusNode = FocusNode();
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _timeFocusNode = FocusNode();

  final List<SupplierDTO> _supplierList = [];

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
        width: MediaQuery
            .of(context)
            .size
            .width * 0.6,
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

//@1
  Future<Widget> _buildSupplierBox() async {
    if (_supplierList.isEmpty) {
      try {
        //Actualiza lista de proveedores
        await _fetchSupplierList();
      } catch (e) {
        if (kDebugMode) print('Error cargando proveedores: $e');
        throw Exception('Error cargando proveedores: $e');
      }
    }
    return Expanded(
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          CustomDropdown<SupplierDTO>(
            themeData: _themeData,
            modelList: _supplierList,
            model: _supplierList[0],
            callback: (supplier) {
              setState(() {
                _selectedSupplier = {
                  'id': supplier?.supplierId,
                  'name': supplier?.name,
                };
              });
            },
          ),
          const SizedBox(width: 8.0,),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return const SizedBox();
  }

  /*Widget _buildClientOrSupplierBox() {
    if (_selectedMovementType != defaultTextFromDropdownMenu) {
      if (_selectedMovementType == nameMovementType(MovementTypeEnum.purchase)
            || _selectedMovementType == nameMovementType(MovementTypeEnum.returnToSupplier)) {
        return _buildSupplierBox();
      } else if (_selectedMovementType == nameMovementType(MovementTypeEnum.sale)) {
          return _buildClientBox();
      }
    }
    return const SizedBox();
  }*/
  Widget _buildClientOrSupplierBox() {
    if (_selectedMovementType != defaultTextFromDropdownMenu) {
      if (_selectedMovementType == nameMovementType(MovementTypeEnum.purchase) ||
          _selectedMovementType == nameMovementType(MovementTypeEnum.returnToSupplier)) {
        return supplierListFutureBuilder();
      } else
      if (_selectedMovementType == nameMovementType(MovementTypeEnum.sale)) {
        return customerListFutureBuilder();
      }
    }
    return const SizedBox();
  }


  FutureBuilder<Widget> supplierListFutureBuilder() {
    return FutureBuilder<Widget>(
      future: _buildSupplierBox(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            Future.delayed(Duration.zero, ()  {
              if (snapshot.hasData) {
                showMessageConnectionError(context);
              }
            });
            return const SizedBox();
          }
        } else {
          if (snapshot.hasError) showMessageConnectionError(context);
          return const SizedBox();
        }
      },
    );
  }


  void showMessageConnectionError(BuildContext context) {
    return floatingMessage(
                  context: context,
                  text: "Error de conexión",
                  messageTypeEnum: MessageTypeEnum.error
    );
  }

  /*FutureBuilder<Widget> supplierListFutureBuilder() {
    return FutureBuilder<Widget>(
      future: _buildSupplierBox(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Retrasar la llamada a floatingMessage para evitar errores durante la construcción del widget
          Future.delayed(Duration.zero, () {
            floatingMessage(
                context: context,
                text: "Error de conexión",
                messageTypeEnum: MessageTypeEnum.error
            );
          });
        } else if (snapshot.connectionState == ConnectionState.done) {
          // Retorna el resultado de _buildSupplierBox() o SizedBox si es nulo
          return snapshot.data ?? const SizedBox();
        }
        return const SizedBox();
      },
    );
  }*/

  //@2
  FutureBuilder<Widget> customerListFutureBuilder() {
    return FutureBuilder<Widget>(
      future: _buildSupplierBox(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Retrasar la llamada a floatingMessage para evitar errores durante la construcción del widget
          Future.delayed(Duration.zero, () {
            showMessageConnectionError(context);
          });
        } else if (snapshot.connectionState == ConnectionState.done) {
          // Retorna el resultado de _buildSupplierBox() o SizedBox si es nulo
          return snapshot.data ?? const SizedBox();
        }
        return const SizedBox();
      },
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

  Future<void> _fetchSupplierList() async {
    fetchDataObject<SupplierDTO>(
      uri: uriSupplierFindAll,
      classObject: SupplierDTO.empty(),

    ).then((data) {
      setState(() {
        _supplierList.clear();
        _supplierList.addAll(data.cast<SupplierDTO>().map((e) =>
            SupplierDTO(
              supplierId: e.supplierId,
              name: e.name,
              telephone1: e.telephone1,
              telephone2: e.telephone2,
              address: e.address,
              email: e.email,
              notes: e.notes,
            )
        ));
        _supplierList.insert(
            0,
            SupplierDTO(
                name: defaultTextFromDropdownMenu, supplierId: 0, isFirst: true
            )
        );
        // _loading = false;
      });
    });
  }

}

