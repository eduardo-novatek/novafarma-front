import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/nursing_report_dto.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/globals/buildTableCell.dart';
import 'package:novafarma_front/model/globals/requests/fetch_nursing_report_pageable.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/globals/tools/number_formats.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/DTOs/customer_dto2.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/constants.dart'
    show sizePageCustomerNursingReportList, uriCustomerNursingReportPage;
import '../../model/globals/tools/create_text_form_field.dart';
import '../../model/globals/tools/date_time.dart' show dateTimeToStr,
  strDateViewToStrDate;
import '../../model/globals/tools/pagination_bar.dart';
import '../../model/objects/page_object_map.dart';

class NursingReportScreen extends StatefulWidget {
  //VoidCallback es un tipo de función predefinido en Flutter que no acepta
  // parámetros y no devuelve ningún valor. En este caso, se utiliza para
  // definir el tipo del callback onCancel, que se llamará cuando el usuario
  // presione el botón de cancelar
  final ui.VoidCallback onCancel;

  const NursingReportScreen({super.key, required this.onCancel});

  @override
  State<NursingReportScreen> createState() => _NursingReportScreenState();
}

class _NursingReportScreenState extends State<NursingReportScreen> {

  static const double _spaceMenuAndBorder = 30.0;

  final PageObjectMap<CustomerDTO2, List<NursingReportDTO>> _pageObjectMap =
    PageObjectMap.empty();

  final _startDateFilterController = TextEditingController();
  final _endDateFilterController = TextEditingController();

  final _startDateFilterFocusNode = FocusNode();
  final _endDateFilterFocusNode = FocusNode();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _startDateFilterController.dispose();
    _startDateFilterFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
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
            _buildFooter()
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Informe de enfermería',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          //const SizedBox(width: 260.0), // Espacio entre el título y el campo de texto
          Center(
            child: Row(
              children: [
                SizedBox(
                  width: 150.0,
                  child: _startDate(),
                ),
                const SizedBox(width: 16.0,),
                SizedBox(
                  width: 150.0,
                  child: _endDate(),
                ),
              ],
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

  CreateTextFormField _startDate() {
    return CreateTextFormField(
      controller: _startDateFilterController,
      focusNode: _startDateFilterFocusNode,
      dataType: DataTypeEnum.date,
      label: '',
      initialFocus: true,
      viewCharactersCount: false,
      acceptEmpty: false,
      decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.white),
          label: const Text('Fecha inicio'),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.blue.shade300,
          suffixIcon: IconButton(
            onPressed: _clearFilter,
            icon: const Icon(Icons.clear, color: Colors.white),
          ),
      ),
      textStyle: const TextStyle(color: Colors.white),
      onEditingComplete: () =>
        FocusScope.of(context).requestFocus(_endDateFilterFocusNode),
    );
  }

  CreateTextFormField _endDate() {
    return CreateTextFormField(
      controller: _endDateFilterController,
      focusNode: _endDateFilterFocusNode,
      dataType: DataTypeEnum.date,
      label: '',
      viewCharactersCount: false,
      acceptEmpty: false,
      decoration: InputDecoration(
        label: const Text('Fecha fin'),
        labelStyle: const TextStyle(color: Colors.white),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.blue.shade300,
        suffixIcon: IconButton(
          onPressed: _clearFilter,
          icon: const Icon(Icons.clear, color: Colors.white),
        ),
      ),
      textStyle: const TextStyle(color: Colors.white),
      onEditingComplete: () async => await _loadDataPageable(),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.only(right: _spaceMenuAndBorder),
                  itemCount: _pageObjectMap.content.length,
                  itemBuilder: (context, index) {
                    return _buildReportRow(index);
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

  Widget _buildFooter() {
    return _pageObjectMap.totalPages != 0
        ? PaginationBar(
            totalPages: _pageObjectMap.totalPages,
            initialPage: _pageObjectMap.pageNumber + 1,
            onPageChanged: (page) {
              setState(() {
                _pageObjectMap.pageNumber = page - 1;
                _loadDataPageable();
              });
            },
          )
        : const SizedBox.shrink();
  }

  Future<void> _loadDataPageable() async {
    _toggleLoading();
    String startDate = strDateViewToStrDate(_startDateFilterController.text.trim());
    String endDate = strDateViewToStrDate(_endDateFilterController.text.trim());
    await fetchNursingReportPageable(
      uri: '$uriCustomerNursingReportPage'
          '/${startDate}T00:00'
          '/${endDate}T23:59'
          '/${_pageObjectMap.pageNumber}'
          '/$sizePageCustomerNursingReportList',
    ).then((pageObject) {
      _pageObjectMap.content.clear();
      if (pageObject.totalElements == 0) {
        FloatingMessage.show(
          context: context,
          text: 'Sin datos',
          messageTypeEnum: MessageTypeEnum.info
        );
      } else {
        setState(() {
          _pageObjectMap.content.addAll(
              pageObject.content as Map<CustomerDTO2, List<NursingReportDTO>>);
          _updatePageObjectMap(pageObject);
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

  void _clearFilter() {
    if (_startDateFilterController.text.trim().isNotEmpty) {
      setState(() {
        _startDateFilterController.clear();
      });
      _loadDataPageable();
    }
  }

  Widget _buildReportRow(int index) {
    final customer = _pageObjectMap.content.keys.elementAt(index);
    final nursingReports = _pageObjectMap.content[customer] ?? [];
    return ExpansionTile(
      title: Text('${customer.name} - ${customer.document}'),
      children: [
        _buildNursingReportsTable(nursingReports),
      ],
    );
  }

  Widget _buildNursingReportsTable(List<NursingReportDTO> nursingReports) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Fecha y hora')),
          DataColumn(label: Text('Artículo')),
          DataColumn(label: Text('Cantidad')),
          DataColumn(label: Text('P.Unitario')),
        ],
        rows: nursingReports.map((report) {
          return DataRow(
            cells: [
              DataCell(Text(dateTimeToStr(report.dateTime)!)),
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: Text(
                    report.medicine!,
                    softWrap: true,
                    overflow: TextOverflow.visible,  // Evita el truncamiento
                  ),
                ),
              ),
              DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(formatDouble(report.quantity!))
                  )
              ),
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('\$ ${formatDouble(report.unitPrice!)}')
                )
              )
            ],
          );
        }).toList(),
      ),
    );
  }

  void _updatePageObjectMap(PageObjectMap pageObjectResult) {
    _pageObjectMap.pageNumber = pageObjectResult.pageNumber;
    _pageObjectMap.pageSize = pageObjectResult.pageSize;
    _pageObjectMap.totalPages = pageObjectResult.totalPages;
    _pageObjectMap.totalElements = pageObjectResult.totalElements;
    _pageObjectMap.first = pageObjectResult.first;
    _pageObjectMap.last = pageObjectResult.last;
  }

}
