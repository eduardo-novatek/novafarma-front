import 'package:flutter/material.dart';

import '../../model/DTOs/customer_dto1.dart';
import '../../model/globals/constants.dart' show uriCustomerFindAllPage;
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
  }

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
      totalPages: 3,
      initialPage: 0,
      onPageChanged: (page) {

      },
    );
  }

  Future<void> _loadData() async {
    await fetchDataPageable<CustomerDTO1>(
      uri: '$uriCustomerFindAllPage/0/3',
      classObject: CustomerDTO1.empty()
    ).then((pageObject) {
      if (pageObject.totalElements == 0) return Future.value(null);
      setState(() {
        _customerList.addAll(pageObject.content as Iterable<CustomerDTO1>);
      });
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
              child: Icon(
                Icons.note,
                color: customer.notes!.isNotEmpty
                  ? Colors.green
                  : Colors.grey
              ),
            )


          ],
        ),
      ],
    );
  }

}
