import 'package:flutter/cupertino.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Contenido de Medicamentos',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
