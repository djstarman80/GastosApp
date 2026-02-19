import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import '../providers/providers.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/cuota_utils.dart';
import '../../data/models/models.dart';
import '../../data/services/backup_service.dart';

// Import condicional
import 'home_screen_web.dart' if (dart.library.io) 'home_screen_stub.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  final BackupService _backupService = BackupService();
  bool _isLoading = false;

  static const List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  void _mesAnterior() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
  }

  void _mesSiguiente() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
  }

  List<Map<String, dynamic>> _getGastosDelMes(List<dynamic> gastos, List<Tarjeta> tarjetas) {
    final result = <Map<String, dynamic>>[];
    
    for (final g in gastos) {
      final fechaGasto = DateTime.fromMillisecondsSinceEpoch(g.fecha as int);
      double montoMostrar = g.monto;
      
      // Buscar la tarjeta asociada al gasto
      final tarjeta = tarjetas.where((t) => t.id == g.tarjetaId).firstOrNull;
      final fechaCierre = tarjeta?.fechaCierre;
      
      if (g.esRecurrente) {
        // Para gastos recurrentes, se muestran en todos los meses desde el mes de resumen
        final mesResumen = fechaCierre != null 
            ? CuotaUtils.calcularMesResumen(fechaGasto, fechaCierre)
            : fechaGasto;
            
        if (_selectedYear < mesResumen.year || 
            (_selectedYear == mesResumen.year && _selectedMonth >= mesResumen.month)) {
          montoMostrar = g.monto;
          result.add({'gasto': g, 'monto': montoMostrar, 'esRecurrente': true});
        }
      } else if (g.cuotas != null && g.cuotas! > 0) {
        // Para gastos en cuotas, calcular según la fecha de cierre
        if (fechaCierre != null) {
          // Usar lógica de fecha de cierre
          if (CuotaUtils.debeAparecerEnMes(
            fechaGasto, 
            fechaCierre, 
            g.cuotas, 
            _selectedYear, 
            _selectedMonth
          )) {
            montoMostrar = g.monto / g.cuotas!;
            result.add({'gasto': g, 'monto': montoMostrar, 'esRecurrente': false});
          }
        } else {
          // Fallback: usar mes calendario si no hay fecha de cierre
          final mesInicio = fechaGasto.month;
          final anioInicio = fechaGasto.year;
          
          int mesesTranscurridos = (_selectedYear - anioInicio) * 12 + (_selectedMonth - mesInicio);
          if (mesesTranscurridos >= 0 && mesesTranscurridos < g.cuotas!) {
            montoMostrar = g.monto / g.cuotas!;
            result.add({'gasto': g, 'monto': montoMostrar, 'esRecurrente': false});
          }
        }
      } else {
        // Para gastos de contado, usar fecha de cierre para determinar el mes de resumen
        if (fechaCierre != null) {
          final mesResumen = CuotaUtils.calcularMesResumen(fechaGasto, fechaCierre);
          if (mesResumen.year == _selectedYear && mesResumen.month == _selectedMonth) {
            montoMostrar = g.monto;
            result.add({'gasto': g, 'monto': montoMostrar, 'esRecurrente': false});
          }
        } else {
          // Fallback: usar mes calendario si no hay fecha de cierre
          if (fechaGasto.year == _selectedYear && fechaGasto.month == _selectedMonth) {
            montoMostrar = g.monto;
            result.add({'gasto': g, 'monto': montoMostrar, 'esRecurrente': false});
          }
        }
      }
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final gastoState = ref.watch(gastoProvider);
    final usuarioState = ref.watch(usuarioProvider);
    final tarjetaState = ref.watch(tarjetaProvider);

    final monthGastos = _getGastosDelMes(gastoState.gastos, tarjetaState.tarjetas);

    final totalMes = monthGastos.fold(0.0, (sum, g) => sum + (g['monto'] as double));

    final gastosPorUsuario = <int, double>{};
    for (final g in monthGastos) {
      final gasto = g['gasto'];
      gastosPorUsuario[gasto.usuarioId] = (gastosPorUsuario[gasto.usuarioId] ?? 0) + (g['monto'] as double);
    }

    final gastosPorTarjeta = <int, double>{};
    for (final g in monthGastos) {
      final gasto = g['gasto'];
      gastosPorTarjeta[gasto.tarjetaId] = (gastosPorTarjeta[gasto.tarjetaId] ?? 0) + (g['monto'] as double);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('GastosApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Importar JSON',
            onPressed: _isLoading ? null : _importData,
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Exportar JSON',
            onPressed: _isLoading ? null : _exportData,
          ),
          IconButton(
            icon: Icon(
              ref.watch(isDarkModeProvider)
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(settingsProvider.notifier).setDarkMode(
                !ref.read(isDarkModeProvider),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          await ref.read(gastoProvider.notifier).loadGastos();
          await ref.read(usuarioProvider.notifier).loadUsuarios();
          await ref.read(tarjetaProvider.notifier).loadTarjetas();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 40),
                            onPressed: _mesAnterior,
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _meses[_selectedMonth - 1],
                            underline: const SizedBox(),
                            icon: const SizedBox(),
                            dropdownColor: Theme.of(context).colorScheme.primary,
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            items: _meses.map((mes) => 
                              DropdownMenuItem(value: mes, child: Text(mes, style: const TextStyle(color: Colors.white)))
                            ).toList(),
                            onChanged: (mes) => setState(() => _selectedMonth = _meses.indexOf(mes!) + 1),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: _selectedYear,
                            underline: const SizedBox(),
                            icon: const SizedBox(),
                            dropdownColor: Theme.of(context).colorScheme.primary,
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            items: List.generate(5, (i) => DateTime.now().year - 2 + i).map((year) => 
                              DropdownMenuItem(value: year, child: Text('$year', style: const TextStyle(color: Colors.white)))
                            ).toList(),
                            onChanged: (year) => setState(() => _selectedYear = year!),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.white, size: 40),
                            onPressed: _mesSiguiente,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total del Mes',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(totalMes),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Por Usuario',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (gastosPorUsuario.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay gastos este mes'),
                  ),
                )
              else
                ...gastosPorUsuario.entries.map((entry) {
                  final usuario = usuarioState.usuarios
                      .where((u) => u.id == entry.key)
                      .firstOrNull;
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(usuario?.nombre ?? 'Usuario ${entry.key}'),
                      trailing: Text(
                        CurrencyFormatter.format(entry.value),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => context.push('/user_expenses/${entry.key}?year=$_selectedYear&month=$_selectedMonth'),
                    ),
                  );
                }),
              const SizedBox(height: 24),
              const Text(
                'Por Tarjeta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (gastosPorTarjeta.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay gastos este mes'),
                  ),
                )
              else
                ...gastosPorTarjeta.entries.map((entry) {
                  final tarjeta = tarjetaState.tarjetas
                      .where((t) => t.id == entry.key)
                      .firstOrNull;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _parseColor(tarjeta?.color),
                        child: const Icon(Icons.credit_card, color: Colors.white),
                      ),
                      title: Text(tarjeta?.nombre ?? 'Tarjeta ${entry.key}'),
                      trailing: Text(
                        CurrencyFormatter.format(entry.value),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => context.push('/tarjeta_expenses/${entry.key}?year=$_selectedYear&month=$_selectedMonth'),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return Colors.grey;
    try {
      if (colorStr.startsWith('0x')) {
        return Color(int.parse(colorStr));
      } else if (colorStr.startsWith('#')) {
        return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
      }
      return Color(int.parse('0xFF$colorStr'));
    } catch (_) {
      return Colors.grey;
    }
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    try {
      final json = await _backupService.exportToJson();
      
      if (kIsWeb) {
        downloadJson(json, 'backup_gastosapp_${DateTime.now().toIso8601String()}.json');
      } else {
        final bytes = Uint8List.fromList(json.codeUnits);
        await FileSaver.instance.saveFile(
          name: 'backup_gastosapp_${DateTime.now().millisecondsSinceEpoch}',
          bytes: bytes,
          ext: 'json',
          mimeType: MimeType.json,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup exportado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importData() async {
    String? jsonString;
    
    if (kIsWeb) {
      jsonString = await uploadJson();
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        jsonString = await file.readAsString();
      }
    }
    
    if (jsonString == null) return;
 
    final confirmReplace = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar Backup'),
        content: const Text(
          '¿Qué deseas hacer con los datos existentes?\n\n'
          '• Agregar: Se agregarán a los datos actuales\n'
          '• Reemplazar: Se borrarán todos los datos actuales',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Agregar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reemplazar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmReplace == null) return;

    setState(() => _isLoading = true);
    try {
      await _backupService.importData(jsonString, replace: confirmReplace);
      
      await ref.read(usuarioProvider.notifier).loadUsuarios();
      await ref.read(tarjetaProvider.notifier).loadTarjetas();
      await ref.read(gastoProvider.notifier).loadGastos();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup importado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
