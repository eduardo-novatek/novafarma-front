
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/presentation_dto.dart';
import 'package:novafarma_front/model/DTOs/voucher_dto_1.dart';
import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';
import 'package:novafarma_front/model/globals/tools/numberFormats.dart';

import '../../model/DTOs/voucher_item_dto_2.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/tools/fetch_data.dart';
import '../../model/globals/tools/pagination_bar.dart';
import '../../model/objects/error_object.dart';
import '../../model/globals/constants.dart' show sizePageVoucherListOfCustomer,
  uriCustomerFindVouchersPage, uriVoucherFindVoucherItems;
import '../../model/globals/tools/fetch_data_pageable.dart';
import '../../model/globals/tools/floating_message.dart';

class VouchersFromCustomerDialog extends StatefulWidget {
  final int customerId;
  final String customerName;

  const VouchersFromCustomerDialog({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<VouchersFromCustomerDialog> createState() => _VouchersFromCustomerDialogState();
}

class _VouchersFromCustomerDialogState extends State<VouchersFromCustomerDialog> {
  final List<VoucherDTO1> _voucherPageList = [];
  bool _loading = true;
  final Map<String, int> _metadata = {
    'pageNumber': 0,
    'totalPages': 0,
    'totalElements': 0,
  };
  final Map<String, List<VoucherItemDTO2>> _voucherItems = {};
  final Map<String, bool> _voucherLoading = {};

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
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Comprobantes emitidos',
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
              child: Text(
                widget.customerName,
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
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

  ListView _buildListView() {
    return ListView.builder(
      itemCount: _voucherPageList.length,
      itemBuilder: (context, index) {
        final voucher = _voucherPageList[index];
        //final color = index % 2 == 0 ? Colors.white : Colors.grey[200];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ExpansionTile(
            leading: const Icon(Icons.receipt, color: Colors.blue),
            title: _buildTitle(voucher),
            onExpansionChanged: (isExpanded) {
              if (isExpanded && !_voucherItems.containsKey(voucher.voucherId.toString())) {
                _loadVoucherItems(voucher.voucherId.toString());
              }
            },
            children: [
              if (_voucherLoading[voucher.voucherId.toString()] ?? false)
                const ListTile(
                  title: Center(child: CircularProgressIndicator()),
                )
              else if (_voucherItems.containsKey(voucher.voucherId.toString()))
                Table(
                  border: TableBorder.all(color: Colors.blue),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(0.7),
                    3: FlexColumnWidth(0.8),
                  },
                  children: [
                    TableRow(children: [
                      _buildTableCell(text: 'Medicamento', bold: true, size: 14),
                      _buildTableCell(text: 'Presentación', bold: true, size: 14),
                      _buildTableCell(text: 'Cantidad', bold: true, size: 14),
                      _buildTableCell(text: 'P.Unitario', bold: true, size: 14),
                    ]),
                    ..._voucherItems[voucher.voucherId.toString()]!.map((item) {
                      return TableRow(children: [
                        _buildTableCell(text: item.medicine!.name!),
                        _buildTableCell(
                          text: _buildPresentation(item.medicine!.presentation!),
                        ),
                        _buildTableCell(text: item.quantity.toString()),
                        _buildTableCell(
                            text: '\$${formatDouble(item.unitPrice!)}',
                            rightAlign: true
                        ),
                      ]);
                    }),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  TableCell _buildTableCell({
    required String text,
    bool bold = false,
    bool rightAlign = false,
    double size = 13}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: size,
          ),
          textAlign: rightAlign ? TextAlign.end : TextAlign.start,
        ),
      ),
    );

  }

  Widget _buildTitle(VoucherDTO1 voucher) {
    return Text(
      '${dateTimeToStr(voucher.dateTime)} '
          '   |    Tipo: ${nameMovementType(voucher.movementType!)}'
          '   |    Total: \$${voucher.total} '
          "${voucher.notes != null && voucher.notes!.isNotEmpty ? '\nNotas: ${voucher.notes}' : ''}",
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
    );
  }

  Future<void> _loadDataPageable() async {
    _setLoading(true);
    await fetchDataPageable(
      uri: '$uriCustomerFindVouchersPage'
          '/${widget.customerId}'
          '/${_metadata['pageNumber']!}'
          '/$sizePageVoucherListOfCustomer',
      classObject: VoucherDTO1.empty(),
    ).then((pageObject) {
      setState(() {
        _voucherPageList.clear();
        _voucherPageList.addAll(pageObject.content as Iterable<VoucherDTO1>);
        _metadata['pageNumber'] = pageObject.pageNumber;
        _metadata['totalPages'] = pageObject.totalPages;
        _metadata['totalElements'] = pageObject.totalElements;
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

  void _setLoading(bool value) {
    setState(() {
      _loading = value;
    });
  }

  Future<void> _loadVoucherItems(String voucherId) async {
    setState(() {
      _voucherLoading[voucherId] = true;
    });

    await fetchData(
      uri: '$uriVoucherFindVoucherItems/$voucherId',
      classObject: VoucherItemDTO2.empty(),
    ).then((dataList) {
      setState(() {
        _voucherItems[voucherId] =
            dataList.map((item) => item as VoucherItemDTO2).toList();
        _voucherLoading[voucherId] = false;
      });
    }).onError((error, stackTrace) {
      print(error);
      setState(() {
        _voucherLoading[voucherId] = false;
      });
    });
  }

  Widget _buildControlledIcon(bool controlled) {
    return controlled
        ? const Icon(
      Icons.copyright,
      color: Colors.red,
    )
        : const SizedBox.shrink();
  }

  String _buildPresentation(PresentationDTO presentation) {
    return '${presentation.name} ${presentation.quantity} ${presentation.unitName}';
  }
}


/*
class VouchersFromCustomerDialog extends StatefulWidget {
  final int customerId;
  final String customerName;

  const VouchersFromCustomerDialog({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<VouchersFromCustomerDialog> createState() => _VouchersFromCustomerDialogState();
}

class _VouchersFromCustomerDialogState extends State<VouchersFromCustomerDialog> {
  final List<VoucherDTO1> _voucherPageList = [];
  bool _loading = true;
  final Map<String, int> _metadata = {
    'pageNumber': 0,
    'totalPages': 0,
    'totalElements': 0,
  };
  final Map<String, List<VoucherItemDTO2>> _voucherItems = {};

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
            color: Colors.white54, // Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4, // 40% del ancho de la pantalla
        height: MediaQuery.of(context).size.height * 0.7, // 70% del alto de la pantalla
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Comprobantes emitidos',
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
              child: Text(
                widget.customerName,
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
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

  ListView _buildListView() {
    return ListView.builder(
      itemCount: _voucherPageList.length,
      itemBuilder: (context, index) {
        final voucher = _voucherPageList[index];
        return ExpansionTile(
          title: _buildTitle(voucher),
          children: [
            if (_voucherItems.containsKey(voucher.voucherId.toString()))
              ..._voucherItems[voucher.voucherId.toString()]!.map((item) {
                return ListTile(
                  title: _buildVoucherItem(item),
                );
              }).toList()
            else
              ListTile(
                title: const Text('Cargando...'),
                onTap: () => _loadVoucherItems(voucher.voucherId.toString()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildVoucherItem(VoucherItemDTO2 item) {
    return Row(
      children: [
        _buildControlledIcon(item.medicine!.controlled!),
        Text(
          '${item.medicine!.name}, '
          '${_buildPresentation(item.medicine!.presentation!)}, '
          'Cantidad: ${item.quantity}, '
          'P.Unitario: \$${item.unitPrice}',
        ),
      ],
    );
  }

  Widget _buildTitle(VoucherDTO1 voucher) {
    return Text(
      '${dateTimeToStr(voucher.dateTime)} '
      '   |    Tipo: ${nameMovementType(voucher.movementType!)}'
      '   |    Total: \$${voucher.total} '
      "${voucher.notes != null && voucher.notes!.isNotEmpty
          ? '\nNotas: ${voucher.notes}'
          : ''
      }",
    );
  }

  Future<void> _loadDataPageable() async {
    _setLoading(true);
    await fetchDataPageable(
      uri: '$uriCustomerFindVouchersPage'
          '/${widget.customerId}'
          '/${_metadata['pageNumber']!}'
          '/$sizePageVoucherListOfCustomer',
      classObject: VoucherDTO1.empty(),
    ).then((pageObject) {
      setState(() {
        _voucherPageList.clear();
        _voucherPageList.addAll(pageObject.content as Iterable<VoucherDTO1>);
        _metadata['pageNumber'] = pageObject.pageNumber;
        _metadata['totalPages'] = pageObject.totalPages;
        _metadata['totalElements'] = pageObject.totalElements;
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

  void _setLoading(bool value) {
    setState(() {
      _loading = value;
    });
  }

  Future<void> _loadVoucherItems(String voucherIdKey) async {
    _setLoading(true);
    await fetchData(
      uri: '$uriVoucherFindVoucherItems/$voucherIdKey',
      classObject: VoucherItemDTO2.empty(),
    ).then((dataList) {
      setState(() {
        _voucherItems[voucherIdKey] = dataList.map((item) => item as VoucherItemDTO2).toList();
      });
    }).onError((error, stackTrace) {
      print(error);
    });
    _setLoading(false);
  }

  Widget _buildControlledIcon(bool controlled) {
    return controlled
      ? const Icon(Icons.copyright, color: Colors.red,)
      : const SizedBox.shrink();
  }

  String _buildPresentation(PresentationDTO presentation) {
    return '${presentation.name} ${presentation.quantity} ${presentation.unitName}';
  }
}*/

