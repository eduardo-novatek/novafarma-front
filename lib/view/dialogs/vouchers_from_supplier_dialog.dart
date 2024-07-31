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
import '../../model/objects/error_object.dart';
import '../../model/globals/constants.dart' show uriSupplierFindVouchers,
  uriVoucherFindVoucherItems;
import '../../model/globals/tools/floating_message.dart';

class VouchersFromSupplierDialog extends StatefulWidget {
  final int supplierId;
  final String supplierName;

  const VouchersFromSupplierDialog({
    super.key,
    required this.supplierId,
    required this.supplierName,
  });

  @override
  State<VouchersFromSupplierDialog> createState() => _VouchersFromSupplierDialogState();
}

class _VouchersFromSupplierDialogState extends State<VouchersFromSupplierDialog> {
  final List<VoucherDTO1> _voucherPageList = [];
  final Map<String, List<VoucherItemDTO2>> _voucherItems = {};
  final Map<String, bool> _voucherLoading = {};

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
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
            _buildHead(context),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildListView(),
            ),
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
                'Comprobantes',
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
            widget.supplierName,
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        ),
      ],
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
            title: _buildVoucherCardTitle(voucher),
            onExpansionChanged: (isExpanded) {
              // Si al expandir, los items del voucher no estan cargados, los carga
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
                        _buildTableCell(
                          text: item.medicine!.name!,
                          iconControlled: item.medicine!.controlled!
                        ),
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
    double size = 13,
    bool iconControlled = false}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Row(
          children: [
            _buildControlledIcon(iconControlled, size),
            Text(
              text,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: size,
              ),
              textAlign: rightAlign ? TextAlign.end : TextAlign.start,
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildVoucherCardTitle(VoucherDTO1 voucher) {
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

  Future<void> _loadData() async {
    _setLoading(true);
    await fetchData(
      uri: '$uriSupplierFindVouchers/${widget.supplierId}',
      classObject: VoucherDTO1.empty(),
    ).then((data) {
      setState(() {
        _voucherPageList.clear();
        _voucherPageList.addAll(data as Iterable<VoucherDTO1>);
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
      if (kDebugMode) print(error);

      setState(() {
        _voucherLoading[voucherId] = false;
      });
    });
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

  String _buildPresentation(PresentationDTO presentation) {
    return '${presentation.name} ${presentation.quantity} ${presentation.unitName}';
  }

}
