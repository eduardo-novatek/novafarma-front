import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/objects/error_object.dart';
import 'package:novafarma_front/view/dialogs/controlled_medication_list_from_customer_dialog.dart';

import '../../model/DTOs/controlled_medication_dto.dart';
import '../../model/DTOs/controlled_medication_dto1.dart';
import '../../model/DTOs/customer_dto1.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/constants.dart'
    show sizePage, uriCustomerDelete, uriCustomerFindAllPage, uriCustomerFindControlledMedications, uriCustomerFindLastnameName;
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
                    return _buildCustomerRow(index);
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
            SizedBox.shrink(), // Celda vacía para boton de menu
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
      if (pageObject.totalElements == 0) {
        metadata['pageNumber'] = 0;
        metadata['totalPages'] = 0;
        metadata['totalElements'] = 0;
        return Future.value(null);
      }
      setState(() {
        _customerList.addAll(pageObject.content as Iterable<CustomerDTO1>);
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

  Table _buildCustomerRow(int index) {
    CustomerDTO1 customerSelected = _customerList[index];

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
                  child: Text(customerSelected.lastname!),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(customerSelected.name),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(customerSelected.document.toString()),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(customerSelected.telephone!),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(dateToStr(customerSelected.addDate!)!),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(customerSelected.paymentNumber!.toString()),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(customerSelected.partner! ? 'SI' : 'NO'),
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
                      color: customerSelected.notes!.isNotEmpty
                          ? Colors.green
                          : Colors.grey,
                    ),
                    tooltip: customerSelected.notes,
                    onPressed: null,
                  ),
                ),
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: PopupMenuButton<int>(
                onSelected: (menuItem) => _onSelected(context, menuItem, index),
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
            ),
          ],
        )
      ],
    );
  }

  void _onSelected(BuildContext context, int menuItem, int index) {
    switch (menuItem) {
      case 0:
        _controlledMedication(index);
        break;
      case 1:
      // Acción para 'Comprobantes emitidos'
        break;
      case 2:
        _delete(index);
        break;
    }
  }

  void _clearFilter() {
    if (_lastnameFilterController.text.trim().isNotEmpty) {
      _lastnameFilterController.clear();
      _loadDataPageable(); // Carga el listado por defecto
    }
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
        await fetchData<CustomerDTO1>(
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

  Future<void> _controlledMedication(int index) async {
    await fetchData(
        uri: '$uriCustomerFindControlledMedications/${_customerList[index].customerId}',
        classObject: ControlledMedicationDTO1.empty(),
    ).then((value) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ControlledMedicationListFromCustomerDialog(
              medications: value as List<ControlledMedicationDTO1>
          );
        },
      );

    }).onError((error, stackTrace) {

    });
  }

}
