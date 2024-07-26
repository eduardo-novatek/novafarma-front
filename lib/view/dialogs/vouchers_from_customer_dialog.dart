import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart' show
  dateToStr;
import 'package:novafarma_front/model/globals/tools/fetch_data_pageable.dart';

import '../../model/DTOs/voucher_dto_1.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/constants.dart' show uriCustomerFindVouchersPage;
import '../../model/globals/tools/floating_message.dart';
import '../../model/objects/error_object.dart';

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

  final List<VoucherDTO1> _voucherList = [];

  bool _loading = false;

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.white54, //Colors.black26,
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
                child: ListView.builder(
                  itemCount: _voucherList.length,
                  itemBuilder: (context, index) {
                    VoucherDTO1 voucher = _voucherList[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.medical_services, color: Colors.blue),
                          title: Text(
                            dateToStr(voucher.date) ?? 'Sin datos',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: _subTitle(voucher),
                        ),
                        const Divider(thickness: 1),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subTitle(VoucherDTO1 voucher) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tipo: ${nameMovementTypeFromInteger(voucher.movementType!.index)}'),
        Text('Total: \$ ${voucher.total}'),
        Text('Notas: ${voucher.notes}'),
      ],
    );
  }

  Future<void> _loadData() async {
    _toggleLoading();
    await fetchDataPageable(
    uri: '$uriCustomerFindVouchersPage'
        '/${widget.customerId}'
        '/${0}'
        '/${30}',
    classObject: VoucherDTO1.empty(),
    ).then((value) {
      _toggleLoading();
      _voucherList.clear();
      _voucherList.addAll(value.content as Iterable<VoucherDTO1>);

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
}


