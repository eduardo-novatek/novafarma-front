import '../enums/movement_type_enum.dart';
import 'constants.dart';

Map<String, dynamic> userLogged = {
  'userId': 1,
  'name': 'JUAN',
  'surname': 'PEREZ',
  'role': {
    'roleId': 2,
    'name': 'ADMIN',
  }
};

final List<String> movementTypes = [
  defaultTextFromDropdownMenu,
  nameMovementType(MovementTypeEnum.purchase),
  nameMovementType(MovementTypeEnum.sale),
  nameMovementType(MovementTypeEnum.returnToSupplier),
  nameMovementType(MovementTypeEnum.adjustmentStock),
];
