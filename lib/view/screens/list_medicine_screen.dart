import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/globals/controlled_icon.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/objects/error_object.dart';
import 'package:novafarma_front/model/objects/page_object.dart';

import '../../model/DTOs/medicine_dto1.dart';
import '../../model/DTOs/presentation_dto.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/constants.dart' show sizePageMedicineList,
  uriMedicineDelete, uriMedicineFindAll, uriMedicineFindNamePage;
import '../../model/globals/tools/date_time.dart' show dateToStr;
import '../../model/globals/tools/fetch_data_object.dart';
import '../../model/globals/tools/fetch_data_object_pageable.dart';
import '../../model/globals/tools/open_dialog.dart';
import '../../model/globals/tools/pagination_bar.dart';

class ListMedicineScreen extends StatefulWidget {
  //VoidCallback es un tipo de función predefinido en Flutter que no acepta
  // parámetros y no devuelve ningún valor. En este caso, se utiliza para
  // definir el tipo del callback onCancel, que se llamará cuando el usuario
  // presione el botón de cancelar
  final ui.VoidCallback onCancel;

  const ListMedicineScreen({super.key, required this.onCancel});

  @override
  State<ListMedicineScreen> createState() => _ListMedicineScreenState();
}

class _ListMedicineScreenState extends State<ListMedicineScreen> {

  static const double _spaceMenuAndBorder = 30.0;
  static const double _colControlled = 0.2; //icono
  static const double _colName = 2.5;
  static const double _colPresentation = 1.5;
  static const double _colLastAddDate = 0.8;
  static const double _colCostPrice = 0.7;
  static const double _colSalePrice = 0.7;
  static const double _colStock = 0.7;
  static const double _colMenu = 0.2;

  final _nameFilterController = TextEditingController();
  final _nameFilterFocusNode = FocusNode();

  bool _loading = false;

  final PageObject<MedicineDTO1> _pageObject = PageObject.empty();

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
        width: MediaQuery.of(context).size.width * 0.8,
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
            'Listado de medicamentos',
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
                    _pageObject.pageNumber = 0; //Indica que el filtro cargue la primera pagina
                    _loadDataFilterPageable();
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
                    return _buildMedicineRow(index);
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
          0: FlexColumnWidth(_colControlled),
          1: FlexColumnWidth(_colName),
          2: FlexColumnWidth(_colPresentation),
          3: FlexColumnWidth(_colLastAddDate),
          4: FlexColumnWidth(_colCostPrice),
          5: FlexColumnWidth(_colSalePrice),
          6: FlexColumnWidth(_colStock),
          8: FlexColumnWidth(_colMenu),
        },
        children: [
          TableRow(
            children: [
              const SizedBox.shrink(), // Celda vacía para icono 'controlado'
              _buildColumn('NOMBRE'),
              _buildColumn('PRESENTACIÓN'),
              _buildColumn('ACTUALIZADO'),
              _buildColumn('P.COSTO'),
              _buildColumn('P.VENTA'),
              _buildColumn('STOCK'),
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
    return PaginationBar(
      totalPages: _pageObject.totalPages,
      initialPage: _pageObject.pageNumber + 1,
      onPageChanged: (page) {
        _pageObject.pageNumber = page - 1;
        _nameFilterController.text.trim().isNotEmpty
          ? _loadDataFilterPageable()
          : _loadDataPageable();
      },
    );
  }

  Future<void> _loadDataPageable() async {
    _setLoading(true);
    await fetchDataObjectPageable<MedicineDTO1>(
      uri: '$uriMedicineFindAll/${_pageObject.pageNumber}/$sizePageMedicineList',
      classObject: MedicineDTO1.empty(),
    ).then((pageObjectResult) {
      _pageObject.content.clear();
      _pageObject.content.addAll(
          pageObjectResult.content as Iterable<MedicineDTO1>
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

  Future<void> _loadDataFilterPageable() async {
    if (_nameFilterController.text.trim().isEmpty) {
      _loadDataPageable();
      return;
    }
    _setLoading(true);
    await fetchDataObjectPageable<MedicineDTO1>(
      uri: '$uriMedicineFindNamePage'
          '/${_nameFilterController.text.trim()}'
          '/true' //busqeda con like
          '/true' //incluye eliminados
          '/${_pageObject.pageNumber}'
          '/$sizePageMedicineList',
      classObject: MedicineDTO1.empty(),
    ).then((pageObjectResult) {
      _pageObject.content.clear();
      _pageObject.content.addAll(
          pageObjectResult.content as Iterable<MedicineDTO1>
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

  void _clearFilter() {
    if (_nameFilterController.text.trim().isNotEmpty) {
      _nameFilterController.clear();
      _pageObject.pageNumber = 0; //Indica que cargue la primera pagina
      _loadDataPageable();
    }
  }

  Widget _buildMedicineRow(int index) {
    MedicineDTO1 medicine = _pageObject.content[index];
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
          0: FlexColumnWidth(_colControlled),
          1: FlexColumnWidth(_colName),
          2: FlexColumnWidth(_colPresentation),
          3: FlexColumnWidth(_colLastAddDate),
          4: FlexColumnWidth(_colCostPrice),
          5: FlexColumnWidth(_colSalePrice),
          6: FlexColumnWidth(_colStock),
          8: FlexColumnWidth(_colMenu),
        },
        children: [
          TableRow(
            children: [
              _buildControlledIcon(medicine),
              _buildTableCell(text: medicine.name),
              _buildTableCell(text: _buildPresentation(medicine.presentation!)),
              _buildTableCell(text: dateToStr(medicine.lastAddDate!)),
              _buildTableCell(text: medicine.lastCostPrice!.toString()),
              _buildTableCell(text: medicine.lastSalePrice!.toString()),
              _buildTableCell(text: medicine.currentStock!.toString()),
              _showMenu(index),
            ],
          )
        ],
      ),
    );
  }

  TableCell _buildControlledIcon(MedicineDTO1 medicine) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: medicine.controlled != null && medicine.controlled!
        ? controlledIcon()
        : const SizedBox.shrink()
    );
  }

  String? _buildPresentation(PresentationDTO presentation) =>
    '${presentation.name} ${presentation.quantity} ${presentation.unitName}';

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
                Icon(Icons.medical_information, color: Colors.black),
                SizedBox(width: 8),
                Text('opcion 1')
              ],
            ),
          ),
          const PopupMenuItem<int>(
            value: 1,
            child: Row(
              children: [
                Icon(Icons.assignment_outlined, color: Colors.black),
                SizedBox(width: 8),
                Text('opcion 2')
              ],
            ),
          ),
          const PopupMenuItem<int>(
            value: 2,
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
          )
        ),
      ),
    );
  }

  void _onSelected(BuildContext context, int menuItem, int index) {
    switch (menuItem) {
      case 0:
        //_controlledMedications(index);
        break;
      case 1:
        //_vouchersCustomer(index);
        break;
      case 2:
        _delete(index);
        break;
    }
  }

 /* Future<void> _vouchersCustomer(int index) async {
    _toggleLoading();
    //Verifico la existencia de por lo menos un voucher
    await fetchDataObjectPageable(
        uri: '$uriCustomerFindVouchersPage/${_medicineList[index].customerId}/0/1',
        classObject: VoucherDTO1.empty(),
    ).then((pageObject) {
     if (pageObject.totalElements == 0) {
       FloatingMessage.show(
         context: context,
         text: 'Sin datos',
         messageTypeEnum: MessageTypeEnum.info,
       );
     } else {
       CustomerDTO1 customer = _medicineList[index];
       showDialog(
         context: context,
         builder: (context) {
           return AlertDialog(
             content: VouchersFromCustomerDialog(
               customerId: customer.customerId!,
               customerName: '${customer.lastname}, ${customer.name}',
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
  }*/

 /* Future<void> _controlledMedications(int index) async {
    _toggleLoading();
    await fetchDataObject(
      uri: '$uriCustomerFindControlledMedications/${_medicineList[index].customerId}',
      classObject: ControlledMedicationDTO1.empty(),
    ).then((value) {
      _toggleLoading();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ControlledMedicationListFromCustomerDialog(
              customerName: '${_medicineList[index].lastname}, '
                  '${_medicineList[index].name}',
              medications: value as List<ControlledMedicationDTO1>
          );
        },
      );
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
        genericError(error!, context, isFloatingMessage: true);
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
  }*/

  Future<void> _delete(int index) async {
    MedicineDTO1 medicineSelected = _pageObject.content[index];

    int option = await OpenDialog(
      context: context,
      title: 'Eliminar medicamento',
      content: '${medicineSelected.name} '
          '${medicineSelected.presentation!.name} '
          '${medicineSelected.presentation!.quantity} '
          '${medicineSelected.presentation!.unitName} '
          '\n\n'
          '¿Confirma?',
      textButton1: 'Si',
      textButton2: 'No',
    ).view();

    if (option == 1) {
      _setLoading(true);
      try {
        await fetchDataObject<MedicineDTO1>(
          uri: '$uriMedicineDelete/${medicineSelected.medicineId!}',
          classObject: MedicineDTO1.empty(),
        );
        setState(() {
          _pageObject.content.removeAt(index);
        });
        FloatingMessage.show(
          context: context,
          text: 'Medicamento eliminado con éxito',
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
        _setLoading(false);
      }
    }
  }

}
