import 'package:flutter/cupertino.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Contenido de Clientes',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
