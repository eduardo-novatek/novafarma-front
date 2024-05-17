import 'package:flutter/cupertino.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Contenido de Voucher',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
