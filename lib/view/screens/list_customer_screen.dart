import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/objects/error_object.dart';
import 'package:novafarma_front/view/dialogs/controlled_medication_list_from_customer_dialog.dart';

import '../../model/DTOs/controlled_medication_dto1.dart';
import '../../model/DTOs/customer_dto1.dart';
import '../../model/DTOs/voucher_dto_1.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/constants.dart'
    show sizePageCustomerList, uriCustomerDelete, uriCustomerFindAllPage,
    uriCustomerFindControlledMedications, uriCustomerFindLastnameName,
    uriCustomerFindVouchersPage;
import '../../model/globals/tools/date_time.dart' show dateToStr;
import '../../model/globals/tools/fetch_data_object.dart';
import '../../model/globals/tools/fetch_data_object_pageable.dart';
import '../../model/globals/tools/open_dialog.dart';
import '../../model/globals/tools/pagination_bar.dart';
import '../dialogs/vouchers_from_customer_dialog.dart';

class ListCustomerScreen extends StatefulWidget {
  //VoidCallback es un tipo de función predefinido en Flutter que no acepta
  // parámetros y no devuelve ningún valor. En este caso, se utiliza para
  // definir el tipo del callback onCancel, que se llamará cuando el usuario
  // presione el botón de cancelar
  final ui.VoidCallback onCancel;

  const ListCustomerScreen({super.key, required this.onCancel});

  @override
  State<ListCustomerScreen> createState() => _ListCustomerScreenState();
}

class _ListCustomerScreenState extends State<ListCustomerScreen> {

  static const double _spaceMenuAndBorder = 30.0;
  static const double _colLastname = 1.0;
  static const double _colName = 1.0;
  static const double _colDocument = 0.5;
  static const double _colTelephone = 0.5;
  static const double _colAddDate = 0.5;
  static const double _colPayNumber = 0.4;
  static const double _colPartner = 0.3;
  static const double _colNotes = 0.3;
  static const double _colMenu = 0.2;

  final List<CustomerDTO1> _customerList = [];

  final _lastnameFilterController = TextEditingController();
  final _lastnameFilterFocusNode = FocusNode();

  bool _loading = false;
  int _highlightedIndex = -1; //iluminacion de fila al pasar el mouse

  final Map<String, int> _metadata = {
    'pageNumber': 0,
    'totalPages': 0,
    'totalElements': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadDataPageable();
  }

  @override
  void dispose() {
    _lastnameFilterController.dispose();
    _lastnameFilterFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleBar(),
            _buildBody(),
            _lastnameFilterController.text.trim().isEmpty
                ? _buildFooter()
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'Listado de clientes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          //const SizedBox(width: 260.0), // Espacio entre el título y el campo de texto
          Expanded(
            child: Center(
              child: SizedBox(
                width: 300.0,
                child: TextField(
                  controller: _lastnameFilterController,
                  focusNode: _lastnameFilterFocusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Filtrar por apellido',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.blue.shade300,
                    suffixIcon: IconButton(
                      onPressed: _clearFilter,
                      icon: const Icon(Icons.clear, color: Colors.white),
                    ),
                  ),
                  onSubmitted: (value) => _loadDataFilter(),
                ),
              ),
            ),
          ),
          //const SizedBox(width: 260.0), // Espacio entre el campo de texto y el botón de cierre
          IconButton(
            onPressed: widget.onCancel,
            icon: const Icon(Icons.close),
            color: Colors.white,
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: Column(
        children: [
          _columnsBody(),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.only(right: _spaceMenuAndBorder),
                  itemCount: _customerList.length,
                  itemBuilder: (context, index) {
                    return _buildCustomerRow(index);
                  },
                ),
                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _columnsBody() {
    return Padding(
      padding: const EdgeInsets.only(right: _spaceMenuAndBorder),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(_colLastname),
          1: FlexColumnWidth(_colName),
          2: FlexColumnWidth(_colDocument),
          3: FlexColumnWidth(_colTelephone),
          4: FlexColumnWidth(_colAddDate),
          5: FlexColumnWidth(_colPayNumber),
          6: FlexColumnWidth(_colPartner),
          7: FlexColumnWidth(_colNotes),
          8: FlexColumnWidth(_colMenu),
        },
        children: [
          TableRow(
            children: [
              _buildColumn('APELLIDO'),
              _buildColumn('NOMBRE'),
              _buildColumn('DOCUMENTO'),
              _buildColumn('TELEFONO'),
              _buildColumn('ALTA'),
              _buildColumn('Nº COBRO'),
              _buildColumn('SOCIO'),
              _buildColumn('NOTAS'),
              const SizedBox.shrink(), // Celda vacía para boton de menu
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFooter() {
    return _metadata['totalPages'] != 0
        ? PaginationBar(
            totalPages: _metadata['totalPages']!,
            initialPage: _metadata['pageNumber']! + 1,
            onPageChanged: (page) {
              setState(() {
                _metadata['pageNumber'] = page - 1;
                _loadDataPageable();
              });
            },
          )
        : const SizedBox.shrink();
  }

  Future<void> _loadDataPageable() async {
    _toggleLoading();
    await fetchDataObjectPageable<CustomerDTO1>(
      uri: '$uriCustomerFindAllPage/${_metadata['pageNumber']!}/$sizePageCustomerList',
      classObject: CustomerDTO1.empty(),
    ).then((pageObject) {
      _customerList.clear();
      if (pageObject.totalElements == 0) {
        _metadata['pageNumber'] = 0;
        _metadata['totalPages'] = 0;
        _metadata['totalElements'] = 0;
        return;
      } else {
        setState(() {
          _customerList.addAll(pageObject.content as Iterable<CustomerDTO1>);
          _metadata['pageNumber'] = pageObject.pageNumber;
          _metadata['totalPages'] = pageObject.totalPages;
          _metadata['totalElements'] = pageObject.totalElements;
        });
      }
    }).onError((error, stackTrace) {
      if (error is ErrorObject) {
        FloatingMessage.show(
          context: context,
          text: '${error.message ?? 'Error indeterminado'} (${error.statusCode})',
          messageTypeEnum: error.message != null
              ? MessageTypeEnum.warning
              : MessageTypeEnum.error,
        );
        if (kDebugMode) {
          print('${error.message ?? 'Error indeterminado'} (${error.statusCode})');
        }
      } else {
        FloatingMessage.show(
          context: context,
          text: 'Error obteniendo datos',
          messageTypeEnum: MessageTypeEnum.error,
        );
        if (kDebugMode) {
          print('Error obteniendo datos: ${error.toString()}');
        }
      }
    });
    _toggleLoading();
  }

  void _toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
  }

  Future<void> _loadDataFilter() async {
    if (_lastnameFilterController.text.trim().isEmpty) {
      _loadDataPageable();
      return;
    }
    _toggleLoading();
    await fetchDataObject<CustomerDTO1>(
      uri: '$uriCustomerFindLastnameName/${_lastnameFilterController.text.trim()}',
      classObject: CustomerDTO1.empty(),
    ).then((customersFiltered) {
      _customerList.clear();
      if (customersFiltered.isNotEmpty) {
        setState(() {
          _customerList.addAll(customersFiltered as Iterable<CustomerDTO1>);
        });
      }
    }).onError((error, stackTrace) {
      if (error is ErrorObject) {
        FloatingMessage.show(
          context: context,
          text: '${error.message ?? 'Error indeterminado'} (${error.statusCode})',
          messageTypeEnum: error.message != null
              ? MessageTypeEnum.warning
              : MessageTypeEnum.error,
        );
        if (kDebugMode) {
          print('${error.message ?? 'Error indeterminado'} (${error.statusCode})');
        }
      } else {
        FloatingMessage.show(
          context: context,
          text: 'Error obteniendo datos',
          messageTypeEnum: MessageTypeEnum.error,
        );
        if (kDebugMode) {
          print('Error obteniendo datos: ${error.toString()}');
        }
      }
    });
    _toggleLoading();
  }

  void _clearFilter() {
    if (_lastnameFilterController.text.trim().isNotEmpty) {
      setState(() {
        _lastnameFilterController.clear();
      });
      _loadDataPageable();
    }
  }

  Widget _buildCustomerRow(int index) {
    CustomerDTO1 customer = _customerList[index];
    return MouseRegion(
      onEnter: (_) => setState(() {
        _highlightedIndex = index;
      }),
      onExit: (_) => setState(() {
        _highlightedIndex = -1;
      }),
      child: Container(
        decoration: BoxDecoration(
          color: _highlightedIndex == index
              ? Colors.blue.shade50
              : Colors.white,
          //: (index % 2 == 0 ? Colors.white : Colors.grey.shade100),
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
        ),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(_colLastname),
            1: FlexColumnWidth(_colName),
            2: FlexColumnWidth(_colDocument),
            3: FlexColumnWidth(_colTelephone),
            4: FlexColumnWidth(_colAddDate),
            5: FlexColumnWidth(_colPayNumber),
            6: FlexColumnWidth(_colPartner),
            7: FlexColumnWidth(_colNotes),
            8: FlexColumnWidth(_colMenu),
          },
          children: [
            TableRow(
              children: [
                _buildTableCell(text: customer.lastname),
                _buildTableCell(text: customer.name),
                _buildTableCell(text: customer.document.toString()),
                _buildTableCell(text: customer.telephone.toString()),
                _buildTableCell(text: dateToStr(customer.addDate)),
                _buildTableCell(text: customer.paymentNumber.toString()),
                _buildTableCell(text: customer.partner! ? 'Sí' : 'No'),
                _buildTableCellNotes(customer.notes!),
                _showMenu(index),
              ],
            )
          ],
        ),
      ),
    );
  }

  TableCell _buildTableCellNotes(String notes) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(
              Icons.note,
              color: notes.isNotEmpty ? Colors.green : Colors.grey,
            ),
            tooltip: notes,
            onPressed: null,
          ),
        ),
      ),
    );
  }

  TableCell _showMenu(int index) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: PopupMenuButton<int>(
        onSelected: (menuItem) => _onSelected(context, menuItem, index),
        tooltip: 'Menú',
        itemBuilder: (context) => [
          const PopupMenuItem<int>(
            value: 0,
            child: Row(
              children: [
                Icon(Icons.medical_information, color: Colors.black),
                SizedBox(width: 8),
                Text('Medicamentos controlados')
              ],
            ),
          ),
          const PopupMenuItem<int>(
            value: 1,
            child: Row(
              children: [
                Icon(Icons.assignment_outlined, color: Colors.black),
                SizedBox(width: 8),
                Text('Comprobantes emitidos')
              ],
            ),
          ),
          const PopupMenuItem<int>(
            value: 2,
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.black),
                SizedBox(width: 8),
                Text('Eliminar')
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableCell _buildTableCell({String? text, bool? alignRight}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Align(
          alignment: alignRight != null && alignRight
            ? Alignment.centerRight
            : Alignment.centerLeft,
          child: Text(
            text ?? '',
            overflow: TextOverflow.ellipsis,
          )
        ),
      ),
    );
  }

  void _onSelected(BuildContext context, int menuItem, int index) {
    switch (menuItem) {
      case 0:
        _controlledMedications(index);
        break;
      case 1:
        _vouchersCustomer(index);
        break;
      case 2:
        _delete(index);
        break;
    }
  }

  Future<void> _vouchersCustomer(int index) async {
    _toggleLoading();
    //Verifica la existencia de por lo menos un voucher
    await fetchDataObjectPageable(
        uri: '$uriCustomerFindVouchersPage/${_customerList[index].customerId}/0/1',
        classObject: VoucherDTO1.empty(),
    ).then((pageObject) {
     if (pageObject.totalElements == 0) {
       FloatingMessage.show(
         context: context,
         text: 'Sin datos',
         messageTypeEnum: MessageTypeEnum.info,
       );
     } else {
       CustomerDTO1 customer = _customerList[index];
       showDialog(
         context: context,
         builder: (context) {
           return AlertDialog(
             content: VouchersFromCustomerDialog(
               customerId: customer.customerId!,
               customerName: '${customer.lastname}, ${customer.name}',
             ),
           );
         },
       );
     }
    }).onError((error, stackTrace) {
      String? msg;
      if (error is ErrorObject) {
          msg = error.message;
      } else {
        msg = error.toString().contains('XMLHttpRequest error')
          ? 'Error de conexión'
          : error.toString();
      }
      if (msg != null) {
        FloatingMessage.show(
          context: context,
          text: msg,
          messageTypeEnum: MessageTypeEnum.error,
        );
        if (kDebugMode) print(error);
      }
    });
    _toggleLoading();
  }

  Future<void> _controlledMedications(int index) async {
    _toggleLoading();
    await fetchDataObject(
      uri: '$uriCustomerFindControlledMedications/${_customerList[index].customerId}',
      classObject: ControlledMedicationDTO1.empty(),
    ).then((value) {
      _toggleLoading();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ControlledMedicationListFromCustomerDialog(
              customerName: '${_customerList[index].lastname}, '
                  '${_customerList[index].name}',
              medications: value as List<ControlledMedicationDTO1>
          );
        },
      );
    }).onError((error, stackTrace) {
      _toggleLoading();
      String? msg;
      if (error is ErrorObject) {
        if (error.statusCode == HttpStatus.notFound) {
          FloatingMessage.show(
            context: context,
            text: 'Sin datos',
            messageTypeEnum: MessageTypeEnum.info,
          );
        } else {
          msg = error.message;
        }

      } else {
        genericError(error!, context, isFloatingMessage: true);
      }
      if (msg != null) {
        FloatingMessage.show(
          context: context,
          text: msg,
          messageTypeEnum: MessageTypeEnum.error,
        );
        if (kDebugMode) print(error);
      }
    });
  }

  Future<void> _delete(int index) async {
    CustomerDTO1 customerSelected = _customerList[index];

    int option = await OpenDialog(
      context: context,
      title: 'Eliminar cliente',
      content: '${customerSelected.lastname}, '
          '${customerSelected.name} (${customerSelected.document})\n\n'
          'Una vez eliminado el cliente no podrá recuperarse.\n'
          '¿Confirma?',
      textButton1: 'Si',
      textButton2: 'No',
    ).view();

    if (option == 1) {
      _toggleLoading();
      try {
        await fetchDataObject<CustomerDTO1>(
          uri: '$uriCustomerDelete/${customerSelected.customerId}',
          classObject: CustomerDTO1.empty(),
        );
        setState(() {
          _customerList.removeAt(index);
        });
        FloatingMessage.show(
          context: context,
          text: 'Cliente eliminado con éxito',
          messageTypeEnum: MessageTypeEnum.info,
        );
      } catch (error) {
        if (error is ErrorObject) {
          FloatingMessage.show(
            context: context,
            text: '${error.message ?? 'Error indeterminado'} (${error.statusCode})',
            messageTypeEnum: error.message != null
                ? MessageTypeEnum.warning
                : MessageTypeEnum.error,
          );
          if (kDebugMode) {
            print('${error.message ?? 'Error indeterminado'} (${error.statusCode})');
          }
        } else {
          FloatingMessage.show(
            context: context,
            text: 'Error obteniendo datos',
            messageTypeEnum: MessageTypeEnum.error,
          );
          if (kDebugMode) {
            print('Error obteniendo datos: ${error.toString()}');
          }
        }
      } finally {
        _toggleLoading();
      }
    }
  }

}
