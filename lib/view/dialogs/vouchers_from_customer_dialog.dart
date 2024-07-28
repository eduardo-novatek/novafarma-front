import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:novafarma_front/model/DTOs/voucher_dto_1.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

import '../../model/enums/message_type_enum.dart';
import '../../model/globals/tools/pagination_bar.dart';
import '../../model/objects/error_object.dart';
import '../../model/globals/constants.dart' show sizePageVoucherListOfCustomer,
  uriCustomerFindVouchersPage;
import '../../model/globals/tools/fetch_data_pageable.dart';
import '../../model/globals/tools/floating_message.dart';

///No chequea la existencia de vouchers. Parte de la base que hay por lo menos uno.
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
  late TreeViewController _treeViewController;
  bool _loading = true;
  final Map<String, int> _metadata = {
    'pageNumber': 0,
    'totalPages': 0,
    'totalElements': 0,
  };

  @override
  void initState() {
    super.initState();
    _treeViewController = TreeViewController(children: []);
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
              child: TreeView(
                controller: _treeViewController,
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Future<void> _loadDataPageable() async {
    _toggleLoading();
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
        _updateTreeView();
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
    _toggleLoading();
  }

  void _updateTreeView() {
    List<Node> nodes = _voucherPageList.map((voucher) {
      return Node(
        label: '${dateTimeToStr(voucher.dateTime)}',
        key: voucher.voucherId.toString(),
        children: [], // Agrega los items aquí si los tienes
      );
    }).toList();

    setState(() {
      _treeViewController = TreeViewController(children: nodes);
    });
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

  void _toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
  }
}
