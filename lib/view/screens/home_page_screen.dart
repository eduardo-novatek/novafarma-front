import 'package:flutter/material.dart';
import 'package:novafarma_front/view/screens.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key, required this.title});
  final String title;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  Widget _currentWidget = Container(); // Widget inicial

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () => _openMenu(context),
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
        ),
      ),
      body: Center(
        child: _currentWidget, // Mostrar el widget actual
      ),
    );
  }

  void _openMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(const Offset(0, kToolbarHeight), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(const Offset(0, kToolbarHeight)), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem<String>(
          value: 'vouchers',
          child: Text('Comprobantes'),
        ),
        const PopupMenuItem<String>(
          value: 'customers',
          child: Text('Clientes'),
        ),
        const PopupMenuItem<String>(
          value: 'suppliers',
          child: Text('Proveedores'),
        ),
        const PopupMenuItem<String>(
          value: 'medicines',
          child: Text('Medicamentos'),
        ),
        const PopupMenuItem<String>(
          value: 'balances',
          child: Text('Balances'),
        ),
        const PopupMenuItem<String>(
          value: 'users and roles',
          child: Text('Usuarios y Roles'),
        ),
      ],
      elevation: 8.0,
    ).then((String? result) {
      if (result != null) {
        if (result == 'vouchers'){
          setState(() {
            _currentWidget = _buildVouchersWidget();
          });
        } else if (result == 'customers') {
          setState(() {
            _currentWidget = _buildCustomersWidget();
          });
        } else if (result == 'suppliers') {
          setState(() {
            _currentWidget = _buildSuppliersWidget();
          });
        } else if (result == 'medicines') {
          setState(() {
            _currentWidget = _buildMedicinesWidget();
          });
        } else if (result == 'balances') {
          setState(() {
            _currentWidget = _buildBalancesWidget();
          });
        } else if (result == 'users and roles') {
          setState(() {
            _currentWidget = _buildUsersAndRolesWidget();
          });
        }
      }
    });
  }

  Widget _buildVouchersWidget() {
    return const VoucherScreen();
  }

  Widget _buildCustomersWidget() {
    return const CustomerScreen();
  }

  Widget _buildSuppliersWidget() {
    return const SupplierScreen();
  }

  Widget _buildMedicinesWidget() {
    return const MedicineScreen();
  }

  Widget _buildBalancesWidget() {
    return const BalanceScreen();
  }

  Widget _buildUsersAndRolesWidget() {
    /*return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: const UsersAndRoles(),
    );
     */
    return const UserAndRoleScreen();
  }
}

