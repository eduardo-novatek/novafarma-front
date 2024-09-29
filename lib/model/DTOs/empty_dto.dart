import 'package:novafarma_front/model/globals/deserializable.dart';

class EmptyDTO extends Deserializable<EmptyDTO> {

  EmptyDTO();
  EmptyDTO.empty();

  @override
  EmptyDTO fromJson(Map<String, dynamic> json) {
    return EmptyDTO.empty();
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

}