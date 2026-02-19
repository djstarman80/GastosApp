import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/pdf_generator.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';

class ExportPdfDialog extends ConsumerStatefulWidget {
  const ExportPdfDialog({super.key});

  @override
  ConsumerState<ExportPdfDialog> createState() => _ExportPdfDialogState();
}

class _ExportPdfDialogState extends ConsumerState<ExportPdfDialog> {
  PdfFilterType _selectedFilter = PdfFilterType.todos;
  int? _selectedId;
  bool _isExporting = false;
  static const int _todosId = -1;

  @override
  Widget build(BuildContext context) {
    final usuarios = ref.watch(usuarioProvider).usuarios;
    final tarjetas = ref.watch(tarjetaProvider).tarjetas;

    return AlertDialog(
      title: const Text('Exportar a PDF'),
      content: _isExporting
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando PDF...'),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona el filtro:'),
                const SizedBox(height: 12),
                RadioListTile<PdfFilterType>(
                  title: const Text('Todos los gastos'),
                  value: PdfFilterType.todos,
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                      _selectedId = null;
                    });
                  },
                ),
                RadioListTile<PdfFilterType>(
                  title: const Text('Por usuario'),
                  value: PdfFilterType.porUsuario,
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                      _selectedId = _todosId;
                    });
                  },
                ),
                if (_selectedFilter == PdfFilterType.porUsuario)
                  DropdownButton<int>(
                    value: _selectedId,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: _todosId,
                        child: Text('Todos los usuarios'),
                      ),
                      ...usuarios.map((u) {
                        return DropdownMenuItem(
                          value: u.id,
                          child: Text(u.nombre),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedId = value);
                    },
                  ),
                RadioListTile<PdfFilterType>(
                  title: const Text('Por tarjeta'),
                  value: PdfFilterType.porTarjeta,
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                      _selectedId = _todosId;
                    });
                  },
                ),
                if (_selectedFilter == PdfFilterType.porTarjeta)
                  DropdownButton<int>(
                    value: _selectedId,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: _todosId,
                        child: Text('Todas las tarjetas'),
                      ),
                      ...tarjetas.map((t) {
                        return DropdownMenuItem(
                          value: t.id,
                          child: Text(t.nombre),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedId = value);
                    },
                  ),
              ],
            ),
      actions: _isExporting
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: _canExport() ? () => _exportPdf() : null,
                child: const Text('Exportar'),
              ),
            ],
    );
  }

  bool _canExport() {
    return true;
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);

    try {
      final gastos = ref.read(gastoProvider).gastos;
      final usuarios = ref.read(usuarioProvider).usuarios;
      final tarjetas = ref.read(tarjetaProvider).tarjetas;

      String? filterName;
      int? effectiveFilterId = _selectedId == _todosId ? null : _selectedId;
      
      if (_selectedFilter == PdfFilterType.porUsuario) {
        if (_selectedId == _todosId) {
          filterName = 'Todos los usuarios';
        } else {
          final usuario = usuarios.firstWhere((u) => u.id == _selectedId);
          filterName = usuario.nombre;
        }
      } else if (_selectedFilter == PdfFilterType.porTarjeta) {
        if (_selectedId == _todosId) {
          filterName = 'Todas las tarjetas';
        } else {
          final tarjeta = tarjetas.firstWhere((t) => t.id == _selectedId);
          filterName = tarjeta.nombre;
        }
      }

      final config = PdfExportConfig(
        filterType: _selectedFilter,
        filterId: effectiveFilterId,
        filterName: filterName,
      );

      final bytes = await PDFGenerator.generateGastosPDFBytes(
        gastos: gastos,
        usuarios: usuarios,
        tarjetas: tarjetas,
        config: config,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: 'gastos_${DateTime.now().millisecondsSinceEpoch}',
          bytes: bytes,
          ext: 'pdf',
          mimeType: MimeType.pdf,
        );
      } else {
        final file = await PDFGenerator.generateGastosPDF(
          gastos: gastos,
          usuarios: usuarios,
          tarjetas: tarjetas,
          config: config,
        );
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Resumen de Gastos',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exportado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
