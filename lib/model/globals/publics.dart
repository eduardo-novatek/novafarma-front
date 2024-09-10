import 'package:novafarma_front/model/DTOs/user_dto_2.dart';
import '../enums/movement_type_enum.dart';
import 'constants.dart';

UserDTO2? userLogged = UserDTO2.empty();

final List<String> movementTypes = [
  defaultFirstOption,
  nameMovementType(MovementTypeEnum.purchase),
  nameMovementType(MovementTypeEnum.sale),
  nameMovementType(MovementTypeEnum.returnToSupplier),
  nameMovementType(MovementTypeEnum.adjustmentStock),
];
