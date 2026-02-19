import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static File? _logFile;
  static bool _initialized = false;
  
  static Future<void> init() async {
    if (_initialized) return;
    try {
      final directory = await getApplicationSupportDirectory();
      _logFile = File('${directory.path}/app_log.txt');
      _initialized = true;
      log('=== Aplicación iniciada ===');
    } catch (e) {
      // No podemos loggear el error si no se pudo inicializar
    }
  }
  
  static void log(String message) {
    if (_logFile == null) return;
    try {
      final timestamp = DateTime.now().toIso8601String();
      _logFile!.writeAsStringSync('$timestamp: $message\n', mode: FileMode.append);
    } catch (e) {
      // Ignorar errores de escritura
    }
  }
  
  static void debug(String message) => log('[DEBUG] $message');
  static void error(String message) => log('[ERROR] $message');
  
  static Future<String> getLogContent() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return 'No hay logs';
    }
    return await _logFile!.readAsString();
  }
}
