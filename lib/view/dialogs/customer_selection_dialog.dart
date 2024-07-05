import 'package:flutter/material.dart';

import '../../model/DTOs/customer_dto1.dart';

class CustomerSelectionDialog extends StatelessWidget {
  final List<CustomerDTO1> customers;
  final Function(int) onSelect;

  const CustomerSelectionDialog({
    super.key,
    required this.customers,
    required this.onSelect
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Esquinas rectas
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3, // 30% del ancho de la pantalla
        height: MediaQuery.of(context).size.height * 0.5, // 50% del alto de la pantalla
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8.0,),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(), // Permitir desplazamiento siempre
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return ListTile(
                    title: Text('${customer.lastname}, ${customer.name} (${customer.document})'),
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



/*@override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Container(
                padding: const EdgeInsetsDirectional.all(20.0),
                width: MediaQuery.of(context).size.width * 0.2,
                child: SizedBox(
                  width: double.infinity,
                  child: ListTile(
                    title: Text('${customer.name} ${customer.lastname} (${customer.document})'),
                    onTap: () {
                      onSelect(index); //devuelve el indice seleccionado
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              onSelect(-1); // Se retorna -1 en caso de cancelación
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }*/

}
