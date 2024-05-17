import 'package:flutter/cupertino.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Contenido de Balances',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
