import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/globals/handleError.dart';
import 'package:novafarma_front/model/objects/page_object.dart';

import '../../DTOs/medicine_dto2.dart';
import '../../enums/message_type_enum.dart';
import '../../objects/error_object.dart';
import '../constants.dart' show sizePageMedicineAndPresentationList,
  uriMedicineFindNamePage;
import '../tools/fetch_data_object_pageable.dart';
import '../tools/floating_message.dart';

///Partiendo desde la pagina definida en pageObject.pageNumber, actualiza el
///objeto pageObject con los medicamentos resultantes de buscarlo por nombre.
Future<void> fetchMedicineByNameList({
  required String medicineName,
  required PageObject<MedicineDTO2> pageObject,
  required bool isLike, //true: busqueda es mediante LIKE, false: coincidencia desde la izquierda (mediante indice)
  required bool includeDeleted, //true: incluye los medicamentos marcados como eliminado
  required BuildContext context
}) async {

  await fetchDataObjectPageable<MedicineDTO2>(
    uri: '$uriMedicineFindNamePage'
        '/$medicineName'
        '/$isLike'
        '/$includeDeleted'
        '/${pageObject.pageNumber}'
        '/$sizePageMedicineAndPresentationList',
    classObject: MedicineDTO2.empty(),

  ).then((page) {
    if (page.totalElements == 0) return null;
    //Actualiza pageObject
    pageObject.content.clear();
    pageObject.content.addAll(page.content as Iterable<MedicineDTO2>);
    pageObject.pageNumber = page.pageNumber;
    pageObject.totalPages = page.totalPages;
    pageObject.totalElements = page.totalElements;
    pageObject.pageSize = page.pageSize;
    pageObject.first = page.first;
    pageObject.last = page.last;

  }).onError((error, stackTrace) {
    handleError(error: error, context: context);
  });
}