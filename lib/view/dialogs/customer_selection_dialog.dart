import 'package:flutter/material.dart';

import '../../model/DTOs/customer_dto.dart';

class CustomerSelectionDialog extends StatelessWidget {
  final List<CustomerDTO> customers;
  final Function(int) onSelect;

  const CustomerSelectionDialog({
    super.key,
    required this.customers,
    required this.onSelect
  });

  @override
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
              return ListTile(
                title: Text('${customer.name} ${customer.lastname}'),
                subtitle: Text('${customer.document}'),
                onTap: () {
                  onSelect(index); //devuelve el indice seleccionado
                  Navigator.of(context).pop();
                },
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
  }
}
