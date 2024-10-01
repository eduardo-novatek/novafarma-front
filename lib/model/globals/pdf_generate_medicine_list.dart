import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/DTOs/medicine_dto1.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';
import 'package:novafarma_front/model/globals/tools/number_formats.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart'; // Para formatear la fecha y hora

Future<void> pdfGenerateMedicineList({
  required List<MedicineDTO1> medicineList,
  required String filter,
}) async {

  final pdf = pw.Document();
  final currentDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      orientation: pw.PageOrientation.portrait,
      header: (pw.Context context) => _buildHead(
        currentDate: currentDate,
        filter: filter,
      ),
      build: (pw.Context context) {
        return [
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(150),   // Nombre
              1: const pw.FixedColumnWidth(100),    // Presentación
              2: const pw.FixedColumnWidth(50), // Actualizado
              3: const pw.FixedColumnWidth(45), // P.Costo
              4: const pw.FixedColumnWidth(45), // P.Venta
              5: const pw.FixedColumnWidth(45), // Stock
              6: const pw.FixedColumnWidth(38), // Columna libre para conteo manual
            },
            children: [
              pw.TableRow(
                children: [
                  _buildColumnTitle('Nombre'),
                  _buildColumnTitle('Presentación'),
                  _buildColumnTitle('Actualizado'),
                  _buildColumnTitle('P.Costo'),
                  _buildColumnTitle('P.Venta'),
                  _buildColumnTitle('Stock'),
                  _buildColumnTitle('Conteo M.'),
                ],
              ),
              // Fila vacía para agregar espacio
              pw.TableRow(
                children: List.generate(7, (index) => pw.SizedBox(height: 4.0)),
              ),
              for (var medicine in medicineList)
                pw.TableRow(
                  children: [
                    _buildItem(
                      item: '${_controlled(medicine.controlled!)} ${medicine.name!}',
                      deleted: medicine.deleted!
                    ),
                    _buildItem(
                      item: '${medicine.presentation?.name} '
                        '${medicine.presentation?.quantity} '
                        '${medicine.presentation?.unitName!}',
                      deleted: medicine.deleted!
                    ),
                    _buildItem(
                      item: dateToStr(medicine.lastAddDate!),
                      deleted: medicine.deleted!
                    ),
                    _buildItemNumber(
                      item: medicine.lastCostPrice,
                      deleted: medicine.deleted!
                    ),
                    _buildItemNumber(
                      item: medicine.lastSalePrice,
                      deleted: medicine.deleted!
                    ),
                    _buildItemNumber(
                      item: medicine.currentStock,
                      deleted: medicine.deleted!
                    ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 20)];
      },
      footer: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Divider(),
            pw.Row(
              children: [
                pw.Text(
                  'NovaFarma',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Spacer(),
                pw.Text(
                  'Página ${context.pageNumber} de ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ]
            )
          ]
        );
      },
    ),
  );

  try {
    /*await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );*/
    final pdfData = await pdf.save();
    final blob = html.Blob([pdfData], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'lista-articulos-$currentDate.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    if (kDebugMode) print (e.toString());
  }
}

pw.Column _buildHead({
  required String currentDate,
  required String filter,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Listado de artículos',
            style: const pw.TextStyle(fontSize: 20),
          ),
          pw.Text('Emisión: $currentDate',
            style: pw.TextStyle(
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
      pw.Row(
        children: [
          pw.Text('Filtro: ${filter.isEmpty ? 'desactivado' : filter}',
              style: const pw.TextStyle(fontSize: 10.0)
          ),
        ],
      ),
      pw.SizedBox(height: 20),
    ]
  );
}

pw.Text _buildItem({String? item, bool deleted = false}) =>
  pw.Text(item ?? '',
    style: pw.TextStyle(
      fontSize: 8.0,
      color: deleted
        ? const PdfColor.fromInt(0xFF888888)  // gris
        : const PdfColor.fromInt(0xFF000000), // negro
      decoration: deleted ? pw.TextDecoration.lineThrough : null,
        )
    );


pw.Text _buildItemNumber({double? item, deleted = false}) =>
    pw.Text(
      item != null ? formatDouble(item) : '',
      style: pw.TextStyle(
        fontSize: 8.0,
        color: deleted
            ? const PdfColor.fromInt(0xFF888888)  // gris
            : const PdfColor.fromInt(0xFF000000), // negro
        decoration: deleted ? pw.TextDecoration.lineThrough : null,
      ),
      textAlign: pw.TextAlign.right,
    );

pw.Text _buildColumnTitle(String title) =>
    pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 8.0,
        fontWeight: pw.FontWeight.bold,
      ),
    );

String _controlled(bool isControlled) {
  return isControlled ? '\u00A9' : '';
}
