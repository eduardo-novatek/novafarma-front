// ignore_for_file: use_build_context_synchronously

import 'dart:html';

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/globals/handleError.dart';
import 'package:novafarma_front/model/globals/tools/build_circular_progress.dart';

import '../../model/DTOs/supplier_dto.dart';
import '../../model/globals/constants.dart' show defaultFirstOption;
import '../../model/globals/requests/fetch_supplier_list.dart';
import '../../model/globals/tools/custom_dropdown.dart';
import '../../model/objects/error_object.dart';

class SupplierBox extends StatefulWidget {
  //final int selectedId;
  final bool selectFirst;
  final ValueChanged<SupplierDTO?> onSelectedChanged;
  final ValueChanged<bool>? onRefreshButtonChange;

  const SupplierBox({
    super.key,
    required this.selectFirst,
    this.onRefreshButtonChange,
    //required this.selectedId,
    required this.onSelectedChanged,
  });

  @override
  SupplierBoxState createState() => SupplierBoxState();
}

class SupplierBoxState extends State<SupplierBox> {

  final List<SupplierDTO> _supplierList = [];
  int? _supplierIdSelected;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateSupplierList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _isLoading
            ? Padding(
          padding: const EdgeInsets.all(15.0),
          child: buildCircularProgress(),
        )
            : Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildRefreshButton(),
              const Text('Proveedor:',
                  style: TextStyle(fontSize: 16.0)
              ),
              //_isLoading
              //    ? buildCircularProgress()
              //    : _buildCustomDropdown(),
              _buildCustomDropdown(),
            ],
          ),
        ),
      ],
    );
  }

  IconButton _buildRefreshButton() {
    return IconButton(
      onPressed: () async {
        if (!_isLoading) {
          // llama al callback: esta haciendo el refresh...
          if (widget.onRefreshButtonChange != null) {
            widget.onRefreshButtonChange!(true);
          }
          await _updateSupplierList();
          // llama al callback: no está haciendo el refresh...
          if (widget.onRefreshButtonChange != null) widget
              .onRefreshButtonChange!(false);
        }
      },
      icon: const Tooltip(
        message: 'Actualizar proveedores',
        child: Icon(
          Icons.refresh_rounded,
          color: Colors.blue,
          size: 16.0,
        ),
      ),
    );
  }

  Widget _buildCustomDropdown() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: CustomDropdown<SupplierDTO>(
          themeData: ThemeData(),
          optionList: _supplierList,
          selectedOption: _supplierList.isNotEmpty
              ? _supplierList.firstWhere((e) =>
          e.supplierId == _supplierIdSelected)
              : null,
          isSelected: !widget.selectFirst,
          callback: (supplier) {
            setState(() {
              if (supplier!.supplierId == 0) {
                _supplierIdSelected = 0;
                widget.onSelectedChanged(null);
              } else {
                _supplierIdSelected = supplier.supplierId;
                widget.onSelectedChanged(
                    SupplierDTO(
                      supplierId: supplier.supplierId,
                      name: supplier.name,
                      telephone1: supplier.telephone1,
                      telephone2: supplier.telephone2,
                      email: supplier.email,
                      address: supplier.address,
                      notes: supplier.notes,
                    )
                );
              }
            });
          },
        ),
      ),
    );
  }

  Future<void> _updateSupplierList() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await fetchSupplierList(supplierList: _supplierList).then((value) {
        _supplierList.insert(
          0,
          SupplierDTO(
            isFirst: true,
            name: defaultFirstOption,
            supplierId: 0,
          ),
        );
        _supplierIdSelected =
        0; //supplierId = 0, indica defaultTextFromDropdownMenu
        widget.onSelectedChanged(null);
      });
    } catch (error) {
      if (error is! ErrorObject || error.statusCode != HttpStatus.notFound) {
        if (mounted) handleError(error: error, context: context);
      }
    } finally {
      if (_supplierList.isEmpty) {
        _supplierList.add(
          SupplierDTO(
            isFirst: true,
            name: defaultFirstOption,
            supplierId: 0,
          ),
        );
        _supplierIdSelected =
        0; //supplierId = 0, indica defaultTextFromDropdownMenu
        widget.onSelectedChanged(null);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

}



