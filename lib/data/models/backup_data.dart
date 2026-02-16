import 'models.dart';

class BackupData {
  final List<Usuario> usuarios;
  final List<Tarjeta> tarjetas;
  final List<Gasto> gastos;
  final String version;

  BackupData({
    required this.usuarios,
    required this.tarjetas,
    required this.gastos,
    this.version = '1.0',
  });

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      usuarios: (json['usuarios'] as List<dynamic>?)
          ?.map((u) => Usuario.fromMapBackup(u))
          .toList() ?? [],
      tarjetas: (json['tarjetas'] as List<dynamic>?)
          ?.map((t) => Tarjeta.fromMapBackup(t))
          .toList() ?? [],
      gastos: (json['gastos'] as List<dynamic>?)
          ?.map((g) => Gasto.fromMapBackup(g))
          .toList() ?? [],
      version: json['version'] as String? ?? '1.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarios': usuarios.map((u) => u.toMapBackup()).toList(),
      'tarjetas': tarjetas.map((t) => t.toMapBackup()).toList(),
      'gastos': gastos.map((g) => g.toMapBackup()).toList(),
      'version': version,
    };
  }
}
