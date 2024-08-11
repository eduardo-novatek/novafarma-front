import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/objects/page_object.dart';

import '../../DTOs/medicine_dto3.dart';
import '../../enums/message_type_enum.dart';
import '../../objects/error_object.dart';
import '../constants.dart' show sizePageMedicineAndPresentationList,
  uriMedicineFindNamePage;
import '../tools/fetch_data_pageable.dart';
import '../tools/floating_message.dart';

///Partiendo desde la pagina definida en pageObject.pageNumber, actualiza el
///objeto pageObject con los medicamentos resultantes de buscarlo por nombre.
Future<void> fetchMedicineByNameList({
  required String medicineName,
  //required List<MedicineDTO3> medicineList,
  required PageObject<MedicineDTO3> pageObject,
  required bool isLike, //true: busqueda es mediante LIKE, false: coincidencia desde la izquierda (mediante indice)
  //required int pageNumber,
  required BuildContext context
}) async {

  await fetchDataPageable<MedicineDTO3>(
    uri: '$uriMedicineFindNamePage'
        '/$medicineName'
        '/$isLike'
        '/${pageObject.pageNumber}'
        '/$sizePageMedicineAndPresentationList',
    classObject: MedicineDTO3.empty(),

  ).then((page) {
    if (page.totalElements == 0) return null;
    //Actualiza pageObject
    pageObject.content.clear();
    pageObject.content.addAll(page.content as Iterable<MedicineDTO3>);
    pageObject.pageNumber = page.pageNumber;
    pageObject.totalPages = page.totalPages;
    pageObject.totalElements = page.totalElements;
    pageObject.pageSize = page.pageSize;
    pageObject.first = page.first;
    pageObject.last = page.last;

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
}