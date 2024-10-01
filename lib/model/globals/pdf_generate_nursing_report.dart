import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:novafarma_front/model/DTOs/customer_dto2.dart';
import 'package:novafarma_front/model/DTOs/nursing_report_dto.dart';
import 'package:novafarma_front/model/globals/tools/date_time.dart';
import 'package:novafarma_front/model/globals/tools/number_formats.dart';
import 'package:novafarma_front/model/objects/page_object_map.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart'; // Para formatear la fecha y hora

Future<void> pdfGenerateNursingReport({
  required String startDate,
  required String endDate,
  required double total,
  required PageObjectMap<CustomerDTO2, List<NursingReportDTO>> pageObjectMap,
}) async {

  final pdf = pw.Document();
  final currentDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      orientation: pw.PageOrientation.portrait,
      header: (pw.Context context) => _buildHead(
        currentDate: currentDate,
        start: startDate,
        end: endDate,
        total: total
      ),
      build: (pw.Context context) {
        return [
          // Lista de medicamentos para cada cliente
          for (var entry in pageObjectMap.content.entries)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${entry.key.name}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 4.0),
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(70), // Fecha y hora
                    1: const pw.FlexColumnWidth(),    // Artículo, toma el espacio restante
                    2: const pw.FixedColumnWidth(45), // Cantidad
                    3: const pw.FixedColumnWidth(45), // P.Unitario
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        _buildColumnTitle('Fecha y hora'),
                        _buildColumnTitle('Artículo'),
                        _buildColumnTitle('Cantidad'),
                        _buildColumnTitle('P.Unitario'),
                      ],
                    ),
                    for (var report in entry.value)
                      pw.TableRow(
                        children: [
                          _buildItem(dateTimeToStr(report.dateTime)),
                          _buildItem(report.medicine),
                          _buildItemNumber(report.quantity),
                          _buildItemNumber(report.unitPrice),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],
            ),
        ];
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
      ..setAttribute('download', 'informe-enfermeria-$currentDate.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    if (kDebugMode) print (e.toString());
  }
}

pw.Column _buildHead({
  required String start,
  required String end,
  required String currentDate,
  required double total,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Informe de enfermería',
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
          pw.Text('$start al $end',
              style: const pw.TextStyle(fontSize: 10.0)
          ),
          pw.Spacer(),
          pw.Text('Total: ',
            style: pw.TextStyle(
              fontSize: 10.0,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.Text('\$ ${formatDouble(total)}',
            style: pw.TextStyle(
              fontSize: 10.0,
              fontWeight: pw.FontWeight.bold
            )
          ),
        ],
      ),
      pw.SizedBox(height: 20),
    ]
  );
}

pw.Text _buildItem(String? item) =>
    pw.Text(
      item ?? '',
      style: const pw.TextStyle(
        fontSize: 8.0,
      ),
    );

pw.Text _buildItemNumber(double? item) =>
    pw.Text(
      item != null ? formatDouble(item) : '',
      style: const pw.TextStyle(
        fontSize: 8.0,
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
