import 'package:flutter/cupertino.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Contenido de Proveedores',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
