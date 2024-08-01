import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/supplier_dto.dart';
import 'package:novafarma_front/model/globals/tools/fetch_data_pageable.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/DTOs/voucher_dto_1.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/constants.dart'
    show uriSupplierDelete, uriSupplierFindAll, uriSupplierFindVouchers;
import '../../model/globals/tools/fetch_data.dart';
import '../../model/globals/tools/open_dialog.dart';
import '../dialogs/vouchers_from_supplier_dialog.dart';

class ListSupplierScreen extends StatefulWidget {
  //VoidCallback es un tipo de función predefinido en Flutter que no acepta
  // parámetros y no devuelve ningún valor. En este caso, se utiliza para
  // definir el tipo del callback onCancel, que se llamará cuando el usuario
  // presione el botón de cancelar
  final ui.VoidCallback onCancel;

  const ListSupplierScreen({super.key, required this.onCancel});

  @override
  State<ListSupplierScreen> createState() => _ListSupplierScreenState();
}

class _ListSupplierScreenState extends State<ListSupplierScreen> {

  static const double _spaceMenuAndBorder = 30.0;
  static const double _colName = 1.5;
  static const double _colTel1 = 0.5;
  static const double _colTel2 = 0.5;
  static const double _colAddress = 1.2;
  static const double _colEmail = 1.5;
  static const double _colNotes = 0.3;
  static const double _colMenu = 0.2;

  final List<SupplierDTO> _supplierList = [];
  bool _loading = false;

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
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
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
            'Listado de proveedores',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
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

  Widget _buildBody() {
    return Expanded(
      child: Column(
        children: [
          _columnsBody(),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.only(right: _spaceMenuAndBorder),
                  itemCount: _supplierList.length,
                  itemBuilder: (context, index) {
                    return _buildSupplierRow(index);
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

  Widget _columnsBody() {
    return Padding(
      padding: const EdgeInsets.only(right: _spaceMenuAndBorder),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(_colName),
          1: FlexColumnWidth(_colTel1),
          2: FlexColumnWidth(_colTel2),
          3: FlexColumnWidth(_colAddress),
          4: FlexColumnWidth(_colEmail),
          5: FlexColumnWidth(_colNotes),
          6: FlexColumnWidth(_colMenu),
        },
        children: [
          TableRow(
            children: [
              _buildColumn('NOMBRE'),
              _buildColumn('TELÉFONO 1'),
              _buildColumn('TELÉFONO 2'),
              _buildColumn('DIRECCIÓN'),
              _buildColumn('EMAIL'),
              _buildColumn('NOTAS'),
              const SizedBox.shrink(), // Celda vacía para boton de menu
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    _toggleLoading();
    await fetchData<SupplierDTO>(
      uri: uriSupplierFindAll,
      classObject: SupplierDTO.empty(),
    ).then((data) {
      _supplierList.clear();
      setState(() {
        _supplierList.addAll(data as Iterable<SupplierDTO>);
      });
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

  Widget _buildSupplierRow(int index) {
    SupplierDTO supplier = _supplierList[index];
    return Container(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(_colName),
          1: FlexColumnWidth(_colTel1),
          2: FlexColumnWidth(_colTel2),
          3: FlexColumnWidth(_colAddress),
          4: FlexColumnWidth(_colEmail),
          5: FlexColumnWidth(_colNotes),
          6: FlexColumnWidth(_colMenu),
        },
        children: [
          TableRow(
            children: [
              _buildTableCell(text: supplier.name),
              _buildTableCell(text: supplier.telephone1.toString()),
              _buildTableCell(text: supplier.telephone2.toString()),
              _buildTableCell(text: supplier.address),
              _buildTableCell(text: supplier.email),
              _buildTableCellNotes(supplier.notes!),
              _showMenu(index),
            ],
          )
        ],
      ),
    );
  }

  TableCell _buildTableCellNotes(String notes) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(
              Icons.note,
              color: notes.isNotEmpty ? Colors.green : Colors.grey,
            ),
            tooltip: notes,
            onPressed: null,
          ),
        ),
      ),
    );
  }

  TableCell _showMenu(int index) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: PopupMenuButton<int>(
        onSelected: (menuItem) => _onSelected(context, menuItem, index),
        tooltip: 'Menú',
        itemBuilder: (context) => [
          const PopupMenuItem<int>(
            value: 0,
            child: Row(
              children: [
                Icon(Icons.assignment_outlined, color: Colors.black),
                SizedBox(width: 8),
                Text('Comprobantes')
              ],
            ),
          ),
          const PopupMenuItem<int>(
            value: 1,
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
    );
  }

  TableCell _buildTableCell({String? text, bool? alignRight}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Align(
          alignment: alignRight != null && alignRight
            ? Alignment.centerRight
            : Alignment.centerLeft,
          child: Text(
            text ?? '',
            overflow: TextOverflow.ellipsis,
            //style: const TextStyle(fontSize: 14.0),
          )
        ),
      ),
    );
  }

  void _onSelected(BuildContext context, int menuItem, int index) {
    switch (menuItem) {
      case 0:
        _vouchersSupplier(index);
        break;
      case 1:
        _delete(index);
        break;
    }
  }

  Future<void> _vouchersSupplier(int index) async {
    _toggleLoading();
    //Verifico la existencia de por lo menos un voucher
    await fetchDataPageable(
        uri: '$uriSupplierFindVouchers/${_supplierList[index].supplierId}/0/1',
        classObject: VoucherDTO1.empty(),
    ).then((pageObject) {
      if (pageObject.totalElements == 0) {
        FloatingMessage.show(
          context: context,
          text: 'Sin datos',
          messageTypeEnum: MessageTypeEnum.info,
        );
      } else {
        SupplierDTO supplier = _supplierList[index];
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: VouchersFromSupplierDialog(
                supplierId: supplier.supplierId!,
                supplierName: supplier.name,
              ),
            );
          },
        );
      }
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

  Future<void> _delete(int index) async {
    SupplierDTO supplierSelected = _supplierList[index];

    int option = await OpenDialog(
      context: context,
      title: 'Eliminar proveedor',
      content: '${supplierSelected.name}\n\n'
          '¿Confirma?',
      textButton1: 'Si',
      textButton2: 'No',
    ).view();

    if (option == 1) {
      _toggleLoading();
      try {
        await fetchData<SupplierDTO>(
          uri: '$uriSupplierDelete/${supplierSelected.supplierId}/true',
          classObject: SupplierDTO.empty(),
        );
        setState(() {
          _supplierList.removeAt(index);
        });
        FloatingMessage.show(
          context: context,
          text: 'Proveedor eliminado con éxito',
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

}
