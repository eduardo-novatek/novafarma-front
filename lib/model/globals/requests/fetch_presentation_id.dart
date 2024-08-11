import 'package:novafarma_front/model/DTOs/presentation_dto.dart';
import 'package:novafarma_front/model/enums/request_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/fetch_data_object.dart';
import '../constants.dart' show uriPresentationGetId;

Future<int> fetchPresentationId(PresentationDTO presentation) async {
  int presentationId = 0;
  await fetchDataObject<PresentationDTO>(
    uri: uriPresentationGetId,
    classObject: PresentationDTO.empty(),
    requestType: RequestTypeEnum.post,
    body: presentation
  ).then((id) {
    presentationId = id[0] as int;
  }).onError((error, stackTrace) {
    print(error);
  });
  return Future.value(presentationId);
}
