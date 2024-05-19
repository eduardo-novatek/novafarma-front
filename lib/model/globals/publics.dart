import '../enums/movement_type_enum.dart';
import 'constants.dart';

Map<String, dynamic> userLogged = {
  'userId': '',
  'identificationDocument': 0,
  'name': '',
  'surname': '',
  'roles': [],
  'residenceZone': {
    'neighborhoodName': '',
    'cityName': '',
    'departmentName': '',
    'countryName': ''
  }
};

List<String> movementTypes = [
  defaultTextFromDropdownMenu,
  nameMovementType(MovementTypeEnum.purchase),
  nameMovementType(MovementTypeEnum.sale),
  nameMovementType(MovementTypeEnum.returnToSupplier),
  nameMovementType(MovementTypeEnum.adjustmentStock),
];
