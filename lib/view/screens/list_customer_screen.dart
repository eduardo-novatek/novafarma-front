import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/DTOs/customer_dto1.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/constants.dart'
    show uriCustomerFindAllPage, sizePage;
import '../../model/globals/tools/date_time.dart';
import '../../model/globals/tools/fetch_data_pageable.dart';
import '../../model/globals/tools/pagination_bar.dart';

class ListCustomerScreen extends StatefulWidget {
  const ListCustomerScreen({super.key});

  @override
  State<ListCustomerScreen> createState() => _ListCustomerScreenState();
}

class _ListCustomerScreenState extends State<ListCustomerScreen> {

  final List<CustomerDTO1> _customerList = [];
  //int _actualPage = 0;
  bool loading = false;
  Map<String, int> metadata = {
    'pageNumber': 0,
    'totalPages': 0,
    'totalElements': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
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
        'Listado de clientes',
        style: TextStyle(
          color: Colors.white,
          fontSize: 19.0,
        ),
        textAlign: TextAlign.center,
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
          _footerBody(),
        ],
      ),
    );
  }

  /* Widget _buildBody() {
    return Expanded(
      child: Column(
        children: [
          _columnsBody(),
          Expanded(
            child: ListView.builder(
              itemCount: _customerList.length,
              itemBuilder: (context, index) {
                return _buildCustomerRow(_customerList[index], index);
              },
            ),
          ),
          _footerBody(),
        ],
      ),
    );
  }*/

  Table _columnsBody() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.8),  // apellido
        1: FlexColumnWidth(0.8),    // nombre
        2: FlexColumnWidth(0.5),    // documento
        3: FlexColumnWidth(0.5),    // telefono
        4: FlexColumnWidth(0.5),  // fecha de alta
        5: FlexColumnWidth(0.4),  // Num. cobro
        6: FlexColumnWidth(0.3),   // ¿socio?
        7: FlexColumnWidth(0.5),   // boton Notas
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
          ],
        ),
      ],
    );
  }

  Widget _footerBody(){
    return PaginationBar(
      totalPages: metadata['totalPages'] ?? 0,
      initialPage: metadata['pageNumber']! + 1, //1er numero de pagina para mostrar en pantalla: 1
      onPageChanged: (page) {
        setState(() {
          metadata['pageNumber'] = page - 1; //El num. de pagina inicia en 0
          _loadData();
        });
      },
    );
  }

  Future<void> _loadData() async {
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

  Table _buildCustomerRow(CustomerDTO1 customer, int index) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.8),  // apellido
        1: FlexColumnWidth(0.8),    // nombre
        2: FlexColumnWidth(0.5),    // documento
        3: FlexColumnWidth(0.5),    // telefono
        4: FlexColumnWidth(0.5),  // fecha de alta
        5: FlexColumnWidth(0.4),  // Num. cobro
        6: FlexColumnWidth(0.3),   // ¿socio?
        7: FlexColumnWidth(0.5),   // boton Notas
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
          ],
        )

        /*
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(customer.lastname!),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(customer.name),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(customer.document.toString()),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(customer.telephone!),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(dateToStr(customer.addDate!)!),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(customer.paymentNumber!.toString()),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(customer.partner! ? 'SI' : 'NO'),
            ),
            Padding(
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
            )

          ],
        ),
         */
      ],
    );
  }

}
