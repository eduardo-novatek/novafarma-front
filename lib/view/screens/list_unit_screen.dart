import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/request_type_enum.dart';
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/DTOs/unit_dto.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/constants.dart' show uriUnitDelete, uriUnitFindAll;
import '../../model/globals/handleError.dart';
import '../../model/globals/tools/fetch_data_object.dart';
import '../../model/globals/tools/open_dialog.dart';

class ListUnitScreen extends StatefulWidget {
  //VoidCallback es un tipo de función predefinido en Flutter que no acepta
  // parámetros y no devuelve ningún valor. En este caso, se utiliza para
  // definir el tipo del callback onCancel, que se llamará cuando el usuario
  // presione el botón de cancelar
  final ui.VoidCallback onCancel;

  const ListUnitScreen({super.key, required this.onCancel});

  @override
  State<ListUnitScreen> createState() => _ListUnitScreenState();
}

class _ListUnitScreenState extends State<ListUnitScreen> {

  static const double _spaceMenuAndBorder = 30.0;
  static const double _colName = 2.0;
  static const double _colMenu = 0.25;

  final List<UnitDTO> _unitList = [];

  bool _loading = false;
  int _highlightedIndex = -1; //iluminacion de fila al pasar el mouse

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
        width: MediaQuery.of(context).size.width * 0.25,
        height: MediaQuery.of(context).size.height * 0.5,
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
        children: [
          const Text(
            'Listado de unidades de medida',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(), // empuja el botón al extremo derecho
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
                  itemCount: _unitList.length,
                  itemBuilder: (context, index) {
                    return _buildUnitRow(index);
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
          1: FlexColumnWidth(_colMenu),
        },
        children: [
          TableRow(
            children: [
              _buildColumn('NOMBRE'),
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
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFooter() {
    return const SizedBox.shrink();
  }

  Future<void> _loadData() async {
    _setLoading(true);
    await fetchDataObject<UnitDTO>(
      uri: uriUnitFindAll,
      classObject: UnitDTO.empty(),
    ).then((data) {
      _unitList.clear();
      _unitList.addAll(data as Iterable<UnitDTO>);
    }).onError((error, stackTrace) {
      if (mounted) handleError(error: error, context: context);
    });
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  Widget _buildUnitRow(int index) {
    UnitDTO unit = _unitList[index];
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
            0: FlexColumnWidth(_colName),
            1: FlexColumnWidth(_colMenu),
          },
          children: [
            TableRow(
              children: [
                _buildTableCell(text: unit.name,),
                _showMenu(index),
              ],
            )
          ],
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
          /*const PopupMenuItem<int>(
            value: 0,
            child: Row(
              children: [
                Icon(Icons.medical_information, color: Colors.black),
                SizedBox(width: 8),
                Text('opcion 1')
              ],
            ),
          ),*/
          PopupMenuItem<int>(
            value: 0,
            child: _buildDelete(index),
          ),
        ],
      ),
    );
  }

  Row _buildDelete(int index) {
    return const Row(
      children: [
        Icon(Icons.delete, color: Colors.red),
        SizedBox(width: 8),
        Text('Eliminar', style: TextStyle(color: Colors.red),)
      ],
    );
    }

  TableCell _buildTableCell({
    String? text, bool alignRight = false, bool isDeleted = false}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Align(
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(text ?? '',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDeleted ? Colors.grey : Colors.black,
              decoration: isDeleted ? TextDecoration.lineThrough : null
            )
          ),
        )
      ),
    );
  }

  void _onSelected(BuildContext context, int menuItem, int index) {
    switch (menuItem) {
      case 0:
        _delete(index);
        break;
    }
  }

  Future<void> _delete(int index) async {
    UnitDTO unitSelected = _unitList[index];
    int option = await OpenDialog(
      context: context,
      title: 'Eliminar unidad de medida',
      content: 'Una vez eliminada no podrá recuperarse.\n\n'
          '${unitSelected.name}\n\n'
          '¿Confirma?',
      textButton1: 'Si',
      textButton2: 'No',
    ).view();

    if (option == 1) {
      _setLoading(true);
      try {
        await fetchDataObject<UnitDTO>(
          uri: '$uriUnitDelete/${unitSelected.unitId}',
          classObject: UnitDTO.empty(),
          requestType: RequestTypeEnum.delete
        );
        _loadData();
        if (mounted) {
          FloatingMessage.show(
            context: context,
            text: 'Unidad de medida eliminada con éxito',
            messageTypeEnum: MessageTypeEnum.info,
            secondsDelay: 2
          );
        }
      } catch (error) {
        if (error is ErrorObject) {
          if (mounted) {
          FloatingMessage.show(
            context: context,
            text: error.message ?? 'Error indeterminado',
            messageTypeEnum: error.message != null
                ? MessageTypeEnum.warning
                : MessageTypeEnum.error,
            secondsDelay: 5,
          );
        }
          if (kDebugMode) {
            print('${error.message ?? 'Error indeterminado'} (${error.statusCode})');
          }
        } else if (mounted) {
            genericError(error, context);
        }
      } finally {
        _setLoading(false);
      }
    }
  }

}
