import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../data/models/models.dart';

enum PdfFilterType { todos, porUsuario, porTarjeta }

class PdfExportConfig {
  final PdfFilterType filterType;
  final int? filterId;
  final String? filterName;

  PdfExportConfig({
    required this.filterType,
    this.filterId,
    this.filterName,
  });
}

class PDFGenerator {
  static Future<Uint8List> generateGastosPDFBytes({
    required List<Gasto> gastos,
    required List<Usuario> usuarios,
    required List<Tarjeta> tarjetas,
    required PdfExportConfig config,
  }) async {
    initializeDateFormatting('es_ES', null);

    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(
      locale: 'es_UY',
      symbol: '\$',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('d/MM/yyyy');
    final headerDateFormat = DateFormat("d 'de' MMMM 'de' yyyy", 'es_ES');

    List<Gasto> filteredGastos = _filterGastos(gastos, config);
    double total = filteredGastos.fold(0.0, (sum, g) => sum + g.monto);

    String titulo = _getTitulo(config);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(titulo, headerDateFormat),
          pw.SizedBox(height: 20),
          _buildResumen(filteredGastos.length, total, currencyFormat),
          pw.SizedBox(height: 20),
          _buildGastosTable(
            filteredGastos,
            usuarios,
            tarjetas,
            currencyFormat,
            dateFormat,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<io.File> generateGastosPDF({
    required List<Gasto> gastos,
    required List<Usuario> usuarios,
    required List<Tarjeta> tarjetas,
    required PdfExportConfig config,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Use generateGastosPDFBytes for web');
    }

    final bytes = await generateGastosPDFBytes(
      gastos: gastos,
      usuarios: usuarios,
      tarjetas: tarjetas,
      config: config,
    );

    final file = io.File(
      '${(await io.Directory.systemTemp.createTemp()).path}/gastos_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  static List<Gasto> _filterGastos(List<Gasto> gastos, PdfExportConfig config) {
    switch (config.filterType) {
      case PdfFilterType.todos:
        return gastos;
      case PdfFilterType.porUsuario:
        if (config.filterId == null) return gastos;
        return gastos.where((g) => g.usuarioId == config.filterId).toList();
      case PdfFilterType.porTarjeta:
        if (config.filterId == null) return gastos;
        return gastos.where((g) => g.tarjetaId == config.filterId).toList();
    }
  }

  static String _getTitulo(PdfExportConfig config) {
    switch (config.filterType) {
      case PdfFilterType.todos:
        return 'Resumen de Gastos - Todos';
      case PdfFilterType.porUsuario:
        return 'Resumen de Gastos - Usuario: ${config.filterName ?? "Todos"}';
      case PdfFilterType.porTarjeta:
        return 'Resumen de Gastos - Tarjeta: ${config.filterName ?? "Todas"}';
    }
  }

  static pw.Widget _buildHeader(String titulo, DateFormat dateFormat) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'GASTOS APP',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          titulo,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.normal,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Fecha de emisión: ${dateFormat.format(DateTime.now())}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _buildResumen(
    int count,
    double total,
    NumberFormat currencyFormat,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Column(
            children: [
              pw.Text(
                'Cantidad',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
              pw.Text(
                '$count',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ],
          ),
          pw.Column(
            children: [
              pw.Text(
                'Total',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
              pw.Text(
                currencyFormat.format(total),
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildGastosTable(
    List<Gasto> gastos,
    List<Usuario> usuarios,
    List<Tarjeta> tarjetas,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    if (gastos.isEmpty) {
      return pw.Center(
        child: pw.Text(
          'No hay gastos para mostrar',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey500),
        ),
      );
    }

    final sortedGastos = List<Gasto>.from(gastos)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    String getUsuarioName(int usuarioId) {
      final usuario = usuarios.firstWhere(
        (u) => u.id == usuarioId,
        orElse: () => Usuario(id: 0, nombre: 'Desconocido'),
      );
      return usuario.nombre;
    }

    String getTarjetaName(int tarjetaId) {
      final tarjeta = tarjetas.firstWhere(
        (t) => t.id == tarjetaId,
        orElse: () => Tarjeta(
          id: 0,
          tipo: '',
          nombre: 'Desconocida',
          banco: '',
          nombreTarjeta: '',
          color: '#000000',
          usuarioId: 0,
        ),
      );
      return tarjeta.nombre;
    }

    String formatDate(int timestamp) {
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return dateFormat.format(date);
      } catch (e) {
        return '-';
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            'DETALLE DE GASTOS',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.2),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(2),
            4: const pw.FlexColumnWidth(1.3),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.blue50),
              children: [
                _buildHeaderCell('Fecha'),
                _buildHeaderCell('Usuario'),
                _buildHeaderCell('Tarjeta'),
                _buildHeaderCell('Descripción'),
                _buildHeaderCell('Monto'),
              ],
            ),
            ...sortedGastos.map((gasto) {
              return pw.TableRow(
                children: [
                  _buildCell(formatDate(gasto.fecha)),
                  _buildCell(getUsuarioName(gasto.usuarioId)),
                  _buildCell(getTarjetaName(gasto.tarjetaId)),
                  _buildCell(gasto.descripcion),
                  _buildCell(currencyFormat.format(gasto.monto)),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
          color: PdfColors.grey700,
        ),
      ),
    );
  }

  static pw.Widget _buildCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
        maxLines: 2,
      ),
    );
  }
}
