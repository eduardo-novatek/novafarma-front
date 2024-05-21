import 'package:flutter/material.dart';

import '../../model/DTOs/supplier_dto.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/requests/fetch_supplierList.dart';
import '../../model/globals/tools/custom_dropdown.dart';
import '../../model/globals/constants.dart' show defaultTextFromDropdownMenu;
import '../../model/globals/tools/floating_message.dart';

class SupplierBox extends StatefulWidget {
  late final List<SupplierDTO> supplierList;
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateSupplierList();
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
                    if (!_isLoading) {
                      _updateSupplierList();
                    }
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
            _isLoading
                ? const CircularProgressIndicator()
                : CustomDropdown<SupplierDTO>(
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
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSupplierList() async {
    setState(() {
      _isLoading = true;
    });

    try {
       await fetchSupplierList(widget.supplierList).then((value) {
         widget.supplierList.insert(
             0,
             SupplierDTO(
               isFirst: true,
               name: defaultTextFromDropdownMenu,
               supplierId: 0,
             ));
       });

    } catch (error) {
        _showMessageConnectionError(context);

    } finally {
      if (widget.supplierList.isEmpty) {
        widget.supplierList.add(
            SupplierDTO(
              isFirst: true,
              name: defaultTextFromDropdownMenu,
              supplierId: 0,
            ));
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessageConnectionError(BuildContext context) {
    floatingMessage(
      context: context,
      text: "Error de conexión",
      messageTypeEnum: MessageTypeEnum.error,
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