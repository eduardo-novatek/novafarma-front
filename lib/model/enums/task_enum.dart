enum TaskEnum {
  all,                    // Todas las tareas

  // Vouchers
  voucherEmit,            // Emitir vouchers

  // Clientes
  customerAddUpdate,      // Agregar y actualizar clientes
  customerList,           // Listar clientes
  controlledMedicinesSee, // Ver medicamentos controlados de un cliente
  vouchersIssuedSee,      // Ver comprobantes emitidos de un cliente
  deleteCustomer,         // Eliminar un cliente

  // Proveedores
  supplierAddUpdate,      // Agregar y actualizar proveedores
  supplierList,           // Listar proveedores
  vouchersSupplier,       // Ver comprobantes de un proveedor
  deleteSupplier,         // Eliminar un proveedor

  // Articulos - Medicamentos
  medicineAddUpdate,      // Agregar y actualizar medicamento
  medicineList,           // Listar medicamentos
  nursingReport,          // Informe de enfermería
  stockMovementsMedicineSee, // Ver movimientos de stock de un medicamento
  deleteRestoreMedicine,  // Eliminar y recuperar medicamentos

  // Articulos - Presentaciones
  presentationAddUpdate,  // Agregar y actualizar presentaciones
  presentationList,       // Listar presentaciones
  deletePresentation,     // Borrar presentaciones

  // Articulos - Unidades de medida
  unitAddUpdate,          // Agregar y actualizar unidades de medida
  unitList,               // Listar unidades de medida
  deleteUnit              // Borrar unidades de medida
}

/// Convertir desde el enum (flutter) al formato del backend (mayúsculas)
String toBackendFormat(TaskEnum taskEnum) {
  return taskEnum.toString().split('.').last.toUpperCase();
}

/// Convertir desde el formato del backend al formato camelCase de Flutter
String toFlutterFormat(String backendEnum) {
  List<String> parts = backendEnum.toLowerCase().split('_');
  for (int i = 1; i < parts.length; i++) {
    parts[i] = parts[i][0].toUpperCase() + parts[i].substring(1);
  }
  return parts.join('');
}

/// Dado el enum del backend devuelve el TaskEnum de flutter
TaskEnum? toTaskEnumFromBackend(String backendEnum) {
  switch (backendEnum) {
    case 'ALL':
      return TaskEnum.all;
    case 'VOUCHER_EMIT':
      return TaskEnum.voucherEmit;
    case 'CUSTOMER_ADD_UPDATE':
      return TaskEnum.customerAddUpdate;
    case 'CUSTOMER_LIST':
      return TaskEnum.customerList;
    case 'CONTROLLED_MEDICINES_SEE':
      return TaskEnum.controlledMedicinesSee;
    case 'VOUCHERS_ISSUED_SEE':
      return TaskEnum.vouchersIssuedSee;
    case 'DELETE_CUSTOMER':
      return TaskEnum.deleteCustomer;
    case 'SUPPLIER_ADD_UPDATE':
      return TaskEnum.supplierAddUpdate;
    case 'SUPPLIER_LIST':
      return TaskEnum.supplierList;
    case 'VOUCHERS_SUPPLIER':
      return TaskEnum.vouchersSupplier;
    case 'DELETE_SUPPLIER':
      return TaskEnum.deleteSupplier;
    case 'MEDICINE_ADD_UPDATE':
      return TaskEnum.medicineAddUpdate;
    case 'MEDICINE_LIST':
      return TaskEnum.medicineList;
    case 'NURSING_REPORT':
      return TaskEnum.nursingReport;
    case 'STOCK_MOVEMENTS_MEDICINE_SEE':
      return TaskEnum.stockMovementsMedicineSee;
    case 'DELETE_RESTORE_MEDICINE':
      return TaskEnum.deleteRestoreMedicine;
    case 'PRESENTATION_ADD_UPDATE':
      return TaskEnum.presentationAddUpdate;
    case 'PRESENTATION_LIST':
      return TaskEnum.presentationList;
    case 'DELETE_PRESENTATION':
      return TaskEnum.deletePresentation;
    case 'UNIT_ADD_UPDATE':
      return TaskEnum.unitAddUpdate;
    case 'UNIT_LIST':
      return TaskEnum.unitList;
    case 'DELETE_UNIT':
      return TaskEnum.deleteUnit;
    default:
      return null;
  }
}
