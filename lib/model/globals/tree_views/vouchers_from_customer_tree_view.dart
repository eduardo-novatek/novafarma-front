import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:novafarma_front/model/DTOs/voucher_dto_1.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';

import '../../enums/message_type_enum.dart';
import '../../objects/error_object.dart';
import '../constants.dart' show uriCustomerFindVouchersPage;
import '../tools/fetch_data_pageable.dart';
import '../tools/floating_message.dart';

import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

class VouchersFromCustomerTreeView extends StatefulWidget {
  final int customerId;
  final String customerName;

  const VouchersFromCustomerTreeView({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<VouchersFromCustomerTreeView> createState() => _VouchersFromCustomerTreeViewState();
}

class _VouchersFromCustomerTreeViewState extends State<VouchersFromCustomerTreeView> {
  final List<VoucherDTO1> _voucherPageList = [];
  late TreeViewController _treeViewController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _treeViewController = TreeViewController(children: []);
    _loadData();
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
                  ? Center(child: CircularProgressIndicator())
                  : TreeView(
                controller: _treeViewController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    _toggleLoading();
    await fetchDataPageable(
      uri: '$uriCustomerFindVouchersPage/${widget.customerId}/0/30',
      classObject: VoucherDTO1.empty(),
    ).then((value) {
      _voucherPageList.clear();
      _voucherPageList.addAll(value.content as Iterable<VoucherDTO1>);
      _updateTreeView();
      _toggleLoading();

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
  }

  void _toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
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
}
