import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/DTOs/customer_dto1.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/constants.dart'
    show sizePage, uriCustomerDelete, uriCustomerFindAllPage, uriCustomerFindLastnameName;
import '../../model/globals/tools/date_time.dart';
import '../../model/globals/tools/fetch_data.dart';
import '../../model/globals/tools/fetch_data_pageable.dart';
import '../../model/globals/tools/open_dialog.dart';
import '../../model/globals/tools/pagination_bar.dart';

class ListCustomerScreen extends StatefulWidget {
  //VoidCallback es un tipo de función predefinido en Flutter que no acepta
  // parámetros y no devuelve ningún valor. En este caso, se utiliza para
  // definir el tipo del callback onCancel, que se llamará cuando el usuario
  // presione el botón de cancelar
  final VoidCallback onCancel;
  const ListCustomerScreen({super.key, required this.onCancel});

  @override
  State<ListCustomerScreen> createState() => _ListCustomerScreenState();
}

class _ListCustomerScreenState extends State<ListCustomerScreen> {
  final List<CustomerDTO1> _customerList = [];
  List<Color> _iconButtonColors = [];

  final _lastnameFilterController = TextEditingController();
  final _lastnameFilterFocusNode = FocusNode();

  bool loading = false;
  Map<String, int> metadata = {
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
    super.dispose();
    _lastnameFilterController.dispose();
    _lastnameFilterFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
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
            _buildBody(),
            _lastnameFilterController.text.trim().isEmpty
              ? _buldFooter()
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Listado de clientes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19.0,
              ),
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 280.0,
                    child: CreateTextFormField(
                      controller: _lastnameFilterController,
                      focusNode: _lastnameFilterFocusNode,
                      label: 'Filtrar por apellido',
                      dataType: DataTypeEnum.text,
                      textStyle: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.yellow,
                          fontSize: 17
                      ),
                      acceptEmpty: true,
                      maxValueForValidation: 25,
                      viewCharactersCount: false,
                      validate: false,
                      onFieldSubmitted: (value) =>  _loadDataFilter(),
                    ),
                  ),
                ),
                Flexible(
                  child: IconButton(
                    onPressed: () => _clearFilter(),
                    icon: const Icon(Icons.close_outlined),
                    color: Colors.red,
                    iconSize: 15.0,
                    tooltip: 'Borrar filtro',
                  ),
                ),
              ],
            ),
          ),
          // Tercer widget alineado a la derecha
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => widget.onCancel(),
              icon: const Icon(Icons.close),
              tooltip: 'Cerrar',
            ),
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
                  itemCount: _customerList.length,
                  itemBuilder: (context, index) {
                    return _buildCustomerRow(_customerList[index], index);
                  },
                ),
                if (loading)
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

  Table _columnsBody() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.0),  // apellido
        1: FlexColumnWidth(1.0),    // nombre
        2: FlexColumnWidth(0.5),    // documento
        3: FlexColumnWidth(0.5),    // telefono
        4: FlexColumnWidth(0.5),  // fecha de alta
        5: FlexColumnWidth(0.4),  // Num. cobro
        6: FlexColumnWidth(0.3),   // ¿socio?
        7: FlexColumnWidth(0.5),   // boton Notas
        8: FixedColumnWidth(48),  //boton
        9: FixedColumnWidth(48),  //boton
        10: FixedColumnWidth(48),  //boton

      },
      children: const [
        TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("APELLIDO", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("NOMBRE", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('DOCUMENTO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("TELEFONO", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("ALTA", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Nº COBRO", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("SOCIO", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("NOTAS", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox.shrink(), // Celda vacía para boton
            SizedBox.shrink(), // Celda vacía para boton
            SizedBox.shrink()  // Celda vacía para boton
          ],
        ),
      ],
    );
  }

  Widget _buldFooter(){
    return metadata['totalPages'] != 0
      ? PaginationBar(
          totalPages: metadata['totalPages']!,
          initialPage: metadata['pageNumber']! + 1, //1er numero de pagina para mostrar en pantalla: 1
          onPageChanged: (page) {
            setState(() {
              metadata['pageNumber'] = page - 1; //El num. de pagina inicia en 0
              _loadDataPageable();
            });
          },
        )
      : const SizedBox.shrink();
  }

  Future<void> _loadDataPageable() async {
    _toggleLoading();
    await fetchDataPageable<CustomerDTO1>(
      uri: '$uriCustomerFindAllPage/${metadata['pageNumber']!}/$sizePage',
      classObject: CustomerDTO1.empty()

    ).then((pageObject) {
      _customerList.clear();
      _iconButtonColors.clear();

      if (pageObject.totalElements == 0) {
        metadata['pageNumber'] = 0;
        metadata['totalPages'] = 0;
        metadata['totalElements'] = 0;
        return Future.value(null);
      }
      setState(() {
        _customerList.addAll(pageObject.content as Iterable<CustomerDTO1>);
        //_iconButtonColors = List<Color>.filled(_customerList.length, Colors.black54);
        _iconButtonColors = List<Color>.generate(_customerList.length, (index) => Colors.black54); //Mutable
        metadata['pageNumber'] = pageObject.pageNumber;
        metadata['totalPages'] = pageObject.totalPages;
        metadata['totalElements'] = pageObject.totalElements;
      });

    }).onError((error, stackTrace) {
      if (error is ErrorObject) {
        FloatingMessage.show(
          context: context,
          text: '${error.message ?? 'Error indeterminado'} (${error.statusCode})',
          messageTypeEnum: error.message != null
              ? MessageTypeEnum.warning
              : MessageTypeEnum.error
        );
        if (kDebugMode) {
          print('${error.message ?? 'Error indeterminado'} (${error.statusCode})');
        }
      } else {
        FloatingMessage.show(
            context: context,
            text: 'Error obteniendo datos',
            messageTypeEnum: MessageTypeEnum.error
        );
        if (kDebugMode) {
          print('Error obteniendo datos: ${error.toString()}');
        }
      }
      return null;
    });
    _toggleLoading();
  }

  void _toggleLoading() {
    setState(() {
      loading = !loading;
    });
  }

  Future<void> _loadDataFilter() async {
    if (_lastnameFilterController.text.trim().isEmpty) {
      _loadDataPageable(); // carga lista por defecto
      return;
    }
    _toggleLoading();
    await fetchData<CustomerDTO1>(
        uri: '$uriCustomerFindLastnameName/${_lastnameFilterController.text.trim()}',
        classObject: CustomerDTO1.empty()

    ).then((customersFiltered) {
      _customerList.clear();
      _iconButtonColors.clear();

      if (customersFiltered.isNotEmpty) {
        setState(() {
          _customerList.addAll(customersFiltered as Iterable<CustomerDTO1>);
          //_iconButtonColors = List<Color>.filled(_customerList.length, Colors.black54);
          _iconButtonColors = List<Color>.generate(_customerList.length, (index) => Colors.black54); //Mutable
        });
      }

    }).onError((error, stackTrace) {
      if (error is ErrorObject) {
        FloatingMessage.show(
            context: context,
            text: '${error.message ?? 'Error indeterminado'} (${error.statusCode})',
            messageTypeEnum: error.message != null
                ? MessageTypeEnum.warning
                : MessageTypeEnum.error
        );
        if (kDebugMode) {
          print('${error.message ?? 'Error indeterminado'} (${error.statusCode})');
        }
      } else {
        FloatingMessage.show(
            context: context,
            text: 'Error obteniendo datos',
            messageTypeEnum: MessageTypeEnum.error
        );
        if (kDebugMode) {
          print('Error obteniendo datos: ${error.toString()}');
        }
      }
      return null;
    });
    _toggleLoading();
  }

  Table _buildCustomerRow(CustomerDTO1 customer, int index) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.0),  // apellido
        1: FlexColumnWidth(1.0),    // nombre
        2: FlexColumnWidth(0.5),    // documento
        3: FlexColumnWidth(0.5),    // telefono
        4: FlexColumnWidth(0.5),  // fecha de alta
        5: FlexColumnWidth(0.4),  // Num. cobro
        6: FlexColumnWidth(0.3),   // ¿socio?
        7: FlexColumnWidth(0.5),   // boton Notas
        8: FixedColumnWidth(48),  //boton
        9: FixedColumnWidth(48),  //boton
        10: FixedColumnWidth(48)  //boton
      },
      children: [
        TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(customer.lastname!),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(customer.name),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(customer.document.toString()),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(customer.telephone!),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(dateToStr(customer.addDate!)!),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(customer.paymentNumber!.toString()),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(customer.partner! ? 'SI' : 'NO'),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      Icons.note,
                      color: customer.notes!.isNotEmpty
                          ? Colors.green
                          : Colors.grey,
                    ),
                    tooltip: customer.notes,
                    onPressed: null,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.medical_information),
              tooltip: 'Medicamentos controlados',
              onPressed: () {  },
            ),
            IconButton(
              icon: const Icon(Icons.assignment_outlined),
              tooltip: 'Comprobantes emitidos',
              onPressed: () { } ,
            ),
            MouseRegion(
              onEnter: (_) => _deleteButtonOnEnter(index),
              onExit: (_) => _deleteButtonOnExit(index),
              child: IconButton(
                icon: const Icon(Icons.delete),
                color: _iconButtonColors[index],
                tooltip: 'Eliminar',
                onPressed: () => _delete(customer, index),
              ),
            )
          ],
        )
      ],
    );
  }

  void _clearFilter() {
    if (_lastnameFilterController.text.trim().isNotEmpty) {
      _lastnameFilterController.clear();
      _loadDataPageable(); // Carga el listado por defecto
    }
  }

  Future<void> _delete(CustomerDTO1 customer, int index) async {
    int option = await OpenDialog(
      context: context,
      title: 'Eliminar cliente',
      content: '${customer.lastname}, ${customer.name} (${customer.document})\n\n'
          'Una vez eliminado el cliente no podrá recuperarse.\n'
          '¿Confirma?',
      textButton1: 'Si',
      textButton2: 'No',
    ).view();

    if (option == 1) {
      _toggleLoading();
      try {
        await fetchData<CustomerDTO1>(
          uri: '$uriCustomerDelete/${customer.customerId}',
          classObject: CustomerDTO1.empty(),
        );
        setState(() {
          _customerList.removeAt(index);
          _iconButtonColors.removeAt(index);
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

  void _deleteButtonOnEnter(int index) {
    setState(() {
      _iconButtonColors[index] = Colors.red;
    });
  }

  void _deleteButtonOnExit(int index) {
    setState(() {
      _iconButtonColors[index] = Colors.black54;
    });
  }

}
