import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/request_type_enum.dart';
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/objects/error_object.dart';
import 'package:novafarma_front/model/objects/page_object.dart';

import '../../model/DTOs/presentation_dto.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/constants.dart' show sizePagePresentationList,
  uriPresentationDelete, uriPresentationFindAll, uriPresentationFindName;
import '../../model/globals/tools/fetch_data_object.dart';
import '../../model/globals/tools/fetch_data_object_pageable.dart';
import '../../model/globals/tools/open_dialog.dart';
import '../../model/globals/tools/pagination_bar.dart';

class ListPresentationScreen extends StatefulWidget {
  //VoidCallback es un tipo de función predefinido en Flutter que no acepta
  // parámetros y no devuelve ningún valor. En este caso, se utiliza para
  // definir el tipo del callback onCancel, que se llamará cuando el usuario
  // presione el botón de cancelar
  final ui.VoidCallback onCancel;

  const ListPresentationScreen({super.key, required this.onCancel});

  @override
  State<ListPresentationScreen> createState() => _ListPresentationScreenState();
}

class _ListPresentationScreenState extends State<ListPresentationScreen> {

  static const double _spaceMenuAndBorder = 30.0;
  static const double _colName = 2.0;
  static const double _colQuantity = 0.7;
  static const double _colUnitName = 0.7;
  static const double _colMenu = 0.25;

  final _nameFilterController = TextEditingController();
  final _nameFilterFocusNode = FocusNode();

  bool _loading = false;
  int _highlightedIndex = -1; //iluminacion de fila al pasar el mouse

  final PageObject<PresentationDTO> _pageObject = PageObject.empty();

  @override
  void initState() {
    super.initState();
    _loadDataPageable();
  }

  @override
  void dispose() {
    _nameFilterController.dispose();
    _nameFilterFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
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
            'Listado de presentaciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          //const SizedBox(width: 260.0), // Espacio entre el título y el campo de texto
          Expanded(
            child: Center(
              child: SizedBox(
                width: 300.0,
                child: TextField(
                  controller: _nameFilterController,
                  focusNode: _nameFilterFocusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Filtrar por nombre',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.blue.shade300,
                    suffixIcon: IconButton(
                      onPressed: _clearFilter,
                      icon: const Icon(Icons.clear, color: Colors.white),
                    ),
                  ),
                  onSubmitted: (value) {
                    //_pageObject.pageNumber = 0; //Indica que el filtro cargue la primera pagina
                    _loadDataFilter();
                  },
                ),
              ),
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
                  itemCount: _pageObject.content.length,
                  itemBuilder: (context, index) {
                    return _buildPresentationRow(index);
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
          1: FlexColumnWidth(_colQuantity),
          2: FlexColumnWidth(_colUnitName),
          3: FlexColumnWidth(_colMenu),
        },
        children: [
          TableRow(
            children: [
              _buildColumn('NOMBRE'),
              _buildColumn('CANTIDAD'),
              _buildColumn('UNIDAD'),
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
    if(_nameFilterController.text.trim().isNotEmpty) {
      return const SizedBox.shrink();
    }
    return PaginationBar(
      totalPages: _pageObject.totalPages,
      initialPage: _pageObject.pageNumber + 1,
      onPageChanged: (page) {
        _pageObject.pageNumber = page - 1;
        _loadDataPageable();
      },
    );
  }

  Future<void> _loadDataPageable() async {
    _setLoading(true);
    await fetchDataObjectPageable<PresentationDTO>(
      uri: '$uriPresentationFindAll'
          '/${_pageObject.pageNumber}/$sizePagePresentationList',
      classObject: PresentationDTO.empty(),
    ).then((pageObjectResult) {
      _pageObject.content.clear();
      _pageObject.content.addAll(
          pageObjectResult.content as Iterable<PresentationDTO>
      );
      _updatePageObject(pageObjectResult);
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
    _setLoading(false);
  }

  void _updatePageObject(PageObject<dynamic> pageObjectResult) {
    _pageObject.pageNumber = pageObjectResult.pageNumber;
    _pageObject.pageSize = pageObjectResult.pageSize;
    _pageObject.totalPages = pageObjectResult.totalPages;
    _pageObject.totalElements = pageObjectResult.totalElements;
    _pageObject.first = pageObjectResult.first;
    _pageObject.last = pageObjectResult.last;
  }

  void _setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  Future<void> _loadDataFilter() async {
    if (_nameFilterController.text.trim().isEmpty) {
      _loadDataPageable();
      return;
    }
    _setLoading(true);
    await fetchDataObject<PresentationDTO>(
      uri: '$uriPresentationFindName/${_nameFilterController.text.trim()}',
      classObject: PresentationDTO.empty(),
    ).then((data) {
      _pageObject.content.clear();
      _pageObject.content.addAll(
          data as Iterable<PresentationDTO>
      );
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
    _setLoading(false);
  }


  void _clearFilter() {
    if (_nameFilterController.text.trim().isNotEmpty) {
      _nameFilterController.clear();
      _pageObject.pageNumber = 0; //Indica que cargue la primera pagina
      _loadDataPageable();
    }
  }

  Widget _buildPresentationRow(int index) {
    PresentationDTO presentation = _pageObject.content[index];
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
            1: FlexColumnWidth(_colQuantity),
            2: FlexColumnWidth(_colUnitName),
            3: FlexColumnWidth(_colMenu),
          },
          children: [
            TableRow(
              children: [
                _buildTableCell(text: presentation.name,),
                _buildTableCell(text: presentation.quantity!.toString()),
                _buildTableCell(text: presentation.unitName!),
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
    PresentationDTO presentationSelected = _pageObject.content[index];
    //bool isDelete = ! _pageObject.content[index].deleted!;

    int option = await OpenDialog(
      context: context,
      title: 'Eliminar presentación',
      content: 'Una vez eliminada no podrá recuperarse.\n\n'
          '${presentationSelected.name} '
          '${presentationSelected.quantity} '
          '${presentationSelected.unitName} '
          '\n\n'
          '¿Confirma?',
      textButton1: 'Si',
      textButton2: 'No',
    ).view();

    if (option == 1) {
      _setLoading(true);
      try {
        await fetchDataObject<PresentationDTO>(
          uri: '$uriPresentationDelete/${presentationSelected.presentationId}',
          classObject: PresentationDTO.empty(),
          requestType: RequestTypeEnum.delete
        );
        //Recarga la lista
        _nameFilterController.text.trim().isEmpty
          ? _loadDataPageable()
          : _loadDataFilter();

        if (mounted) {
          FloatingMessage.show(
            context: context,
            text: 'Presentación eliminada con éxito',
            messageTypeEnum: MessageTypeEnum.info,
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
            secondsDelay: 8,
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
