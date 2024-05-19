enum MovementTypeEnum {
  purchase,         // COMPRA a proveedor
  sale,             // VENTA a cliente
  returnToSupplier, // DEVOLUCION a un proveedor
  adjustmentStock   // AJUSTE DE STOCK al realizar un balance
}

String nameMovementType(MovementTypeEnum movementTypeEnum) {
  switch (movementTypeEnum) {
    case MovementTypeEnum.purchase:         return "Compra";
    case MovementTypeEnum.sale:             return "Venta";
    case MovementTypeEnum.returnToSupplier: return "Devolución al proveedor";
    case MovementTypeEnum.adjustmentStock:  return "Ajuste de stock";
    default:  return "";
  }
}
