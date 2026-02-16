import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/providers.dart';
import '../../data/services/backup_service.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    try {
      final json = await _backupService.exportToJson();
      
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filePath = '${directory.path}/backup_$timestamp.json';
      
      final file = File(filePath);
      await file.writeAsString(json);
      
      await Share.shareXFiles([XFile(filePath)], text: 'Backup GastosApp');
      
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.single.path;
    if (filePath == null) return;

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
      await _backupService.importFromFile(filePath, replace: confirmReplace);
      
      // Recargar datos
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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Apariencia',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Modo Oscuro'),
                  subtitle: const Text('Activar tema oscuro'),
                  value: settings.isDarkMode,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setDarkMode(value);
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Datos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Exportar Datos'),
                  subtitle: const Text('Exportar a archivo JSON'),
                  onTap: _exportData,
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Importar Datos'),
                  subtitle: const Text('Importar desde archivo JSON'),
                  onTap: _importData,
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Acerca de',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Versión'),
                  subtitle: Text('2.1.0'),
                ),
              ],
            ),
    );
  }
}
