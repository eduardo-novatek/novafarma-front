import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/supplier_dto.dart';

class SupplierSelectionDialog extends StatelessWidget {
  final List<SupplierDTO> suppliers;
  final Function(int) onSelect;

  const SupplierSelectionDialog({
    super.key,
    required this.suppliers,
    required this.onSelect
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Esquinas rectas
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2, // 30% del ancho de la pantalla
        height: MediaQuery.of(context).size.height * 0.5, // 50% del alto de la pantalla
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8.0,),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(), // Permitir desplazamiento siempre
                itemCount: suppliers.length,
                itemBuilder: (context, index) {
                  final supplier = suppliers[index];
                  return ListTile(
                    title: Text(supplier.name),
                    onTap: () {
                      onSelect(index); //devuelve el índice seleccionado
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  onSelect(-1); // Se retorna -1 si pulsa Cancelar
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
