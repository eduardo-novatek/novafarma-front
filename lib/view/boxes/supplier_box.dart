import 'package:flutter/material.dart';

import '../../model/DTOs/supplier_dto.dart';
import '../../model/globals/requests/fetch_supplierList.dart';
import '../../model/globals/tools/custom_dropdown.dart';

class SupplierBox extends StatefulWidget {
  final List<SupplierDTO> supplierList;
  late final Map<String, dynamic> selectedSupplier;

  SupplierBox({
    Key? key,
    required this.supplierList,
    required this.selectedSupplier,
  }) : super(key: key);

  @override
  SupplierBoxState createState() => SupplierBoxState();
}

class SupplierBoxState extends State<SupplierBox> {
  late Future<void> _fetchSupplierListFuture;

  @override
  void initState() {
    super.initState();
    _fetchSupplierListFuture = fetchSupplierList(widget.supplierList);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _fetchSupplierListFuture = fetchSupplierList(widget.supplierList);
                    });
                  },
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.blue,
                    size: 16.0,
                  ),
                ),
                const Text('Proveedor:', style: TextStyle(fontSize: 16.0)),
              ],
            ),
            FutureBuilder<void>(
              future: _fetchSupplierListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CustomDropdown<SupplierDTO>(
                    themeData: ThemeData(),
                    modelList: widget.supplierList,
                    model: widget.supplierList.isNotEmpty ? widget.supplierList[0] : null,
                    callback: (supplier) {
                      setState(() {
                        widget.selectedSupplier = {
                          'id': supplier?.supplierId,
                          'name': supplier?.name,
                        };
                      });
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}


/*class SupplierBox extends StatefulWidget {
  final List<SupplierDTO> supplierList;
  late final Map<String, dynamic> selectedSupplier;

  SupplierBox({
    super.key,
    required this.supplierList,
    required this.selectedSupplier,
  });

  @override
  SupplierBoxState createState() => SupplierBoxState();
}

class SupplierBoxState extends State<SupplierBox> {

   final ThemeData _themeData = ThemeData();

  @override
  void initState() {
    super.initState();
    fetchSupplierList(widget.supplierList); // Carga inicial de proveedores
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () async => await fetchSupplierList(widget.supplierList),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.blue,
                    size: 16.0,
                  ),
                ),
                const Text('Proveedor:', style: TextStyle(fontSize: 16.0)),
              ],
            ),
            Row(
              children: [
                CustomDropdown<SupplierDTO>(
                  themeData: _themeData,
                  modelList: widget.supplierList,
                  model: widget.supplierList[0],
                  callback: (supplier) {
                    setState(() {
                      widget.selectedSupplier = {
                        'id': supplier?.supplierId,
                        'name': supplier?.name,
                      };
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/