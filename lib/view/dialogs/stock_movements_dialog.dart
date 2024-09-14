import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/stock_movement_dto.dart';
import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';
import 'package:novafarma_front/model/globals/tools/number_formats.dart';
import 'package:novafarma_front/model/objects/page_object.dart';

import '../../model/enums/message_type_enum.dart';
import '../../model/globals/build_table_cell.dart';
import '../../model/globals/tools/pagination_bar.dart';
import '../../model/objects/error_object.dart';
import '../../model/globals/constants.dart' show host, port,
  sizePageMedicineStockMovements, uriMedicineFindStockMovements;
import '../../model/globals/tools/fetch_data_object_pageable.dart';
import '../../model/globals/tools/floating_message.dart';

class StockMovementsDialog extends StatefulWidget {
  final int medicineId;
  final String medicineName;
  final bool controlled;
  final bool deleted;

  const StockMovementsDialog({
    super.key,
    required this.medicineId,
    required this.medicineName,
    required this.controlled,
    required this.deleted,
  });

  @override
  State<StockMovementsDialog> createState() => _StockMovementsDialogState();
}

class _StockMovementsDialogState extends State<StockMovementsDialog> {
  final PageObject<StockMovementDTO> _pageObject = PageObject.empty();
  int _highlightedIndex = -1; //iluminacion de fila al pasar el mouse
  bool _loading = true;

  static const double _spaceMenuAndBorder = 30.0;
  static const double _colDateTime = 1.0;
  static const double _colMovementType = 1.3;
  static const double _colQuantity = 0.4;
  static const double _colUnitPrice = 0.4;

  @override
  void initState() {
    super.initState();
    _loadDataPageable();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.white54,
            blurRadius: 10.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHead(context),
            _columns(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildListView(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Column _buildHead(BuildContext context) {
    return Column (
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Movimientos de stock',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlledIcon(widget.controlled, 16.0),
              const SizedBox(width: 8.0,),
              Text(
                widget.medicineName,
                style: TextStyle(
                  fontSize: 15,
                  color: widget.deleted ? Colors.grey : Colors.black54,
                  fontStyle: FontStyle.italic,
                  decoration: widget.deleted ? TextDecoration.lineThrough : null
                )
              ),
              /*widget.deleted
                ? _msgDeleted()
                : const SizedBox.shrink(),
               */
            ],
          ),
        ),
      ],
    );
  }

  Row _msgDeleted() {
    return const Row(
      children: [
        SizedBox(width: 8.0,),
        Text('(eliminado)', style: TextStyle(color: Colors.red),)
      ],
    );
  }

  Widget _columns() {
    return Padding(
      padding: const EdgeInsets.only(right: _spaceMenuAndBorder),
      child:
        Table(
          columnWidths: const {
            0: FlexColumnWidth(_colDateTime),
            1: FlexColumnWidth(_colMovementType),
            2: FlexColumnWidth(_colQuantity),
            3: FlexColumnWidth(_colUnitPrice),
          },
          children: [
            TableRow(
              children: [
                _buildColumn('FECHA Y HORA'),
                _buildColumn('MOVIMIENTO'),
                _buildColumn('CANTIDAD'),
                _buildColumn('P.UNITARIO'),
              ]
            ),
          ]
        ),
    );
  }

  ListView _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.only(right: _spaceMenuAndBorder),
      itemCount: _pageObject.content.length,
      itemBuilder: (context, index) {
        //final color = index % 2 == 0 ? Colors.white : Colors.grey[200];
        StockMovementDTO stockMovement = _pageObject.content[index];
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
                0: FlexColumnWidth(_colDateTime),
                1: FlexColumnWidth(_colMovementType),
                2: FlexColumnWidth(_colQuantity),
                3: FlexColumnWidth(_colUnitPrice),
              },
              children: [
                TableRow(
                  children: [
                    buildTableCell(
                      text: stockMovement.dateTime != null
                          ? dateTimeToStr(stockMovement.dateTime)! : '',
                      size: 14
                    ),
                    buildTableCell(
                        text: stockMovement.movementType != null
                            ? nameMovementType(stockMovement.movementType!)
                            : 'Ingreso al sistema',
                        size: 14
                    ),
                    buildTableCell(
                      text: stockMovement.quantity.toString(),
                      size: 14,
                      rightAlign: true,
                    ),
                    buildTableCell(
                        text: '\$${formatDouble(stockMovement.unitPrice!)}',
                        size: 14,
                        rightAlign: true
                    ),
                  ],
                ),
              ]
            )
          )
        );
      },
    );
  }

  Future<void> _loadDataPageable() async {
    _setLoading(true);

    final uri = Uri(
      scheme: 'http',
      host: host,
      port: port,
      path: uriMedicineFindStockMovements,
      queryParameters: {
        'medicineId': widget.medicineId.toString(),
        'pageNumber': _pageObject.pageNumber.toString(),
        'pageSize': sizePageMedicineStockMovements.toString(),
      },
    );

    await fetchDataObjectPageable<StockMovementDTO>(
      uri: uri,
      isRequestParam: true,
      classObject: StockMovementDTO.empty(),
    ).then((pageObjectResult) {
      setState(() {
        _pageObject.content.clear();
        _pageObject.content.addAll(
            pageObjectResult.content as Iterable<StockMovementDTO>);
       _updatePageObject(pageObjectResult);
      });
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
    _setLoading(false);
  }

  Widget _buildFooter() {
    return _pageObject.totalPages > 0
      ? PaginationBar(
          totalPages: _pageObject.totalPages,
          initialPage: _pageObject.pageNumber + 1,
          onPageChanged: (page) {
            setState(() {
              _pageObject.pageNumber = page - 1;
              _loadDataPageable();
            });
          },
        )
      : const SizedBox.shrink();
  }

  void _setLoading(bool value) {
    setState(() {
      _loading = value;
    });
  }

  Widget _buildColumn(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildControlledIcon(bool controlled, double size) {
    return controlled
        ? Tooltip(
            message: 'Medicamento controlado',
            child: Icon(
                Icons.copyright,
                color: Colors.red,
                size: size,
            ),
          )
        : const SizedBox.shrink();
  }

  void _updatePageObject(PageObject<dynamic> pageObjectResult) {
    _pageObject.pageNumber = pageObjectResult.pageNumber;
    _pageObject.pageSize = pageObjectResult.pageSize;
    _pageObject.totalPages = pageObjectResult.totalPages;
    _pageObject.totalElements = pageObjectResult.totalElements;
    _pageObject.first = pageObjectResult.first;
    _pageObject.last = pageObjectResult.last;
  }

}
