import 'package:drift/drift.dart';
import 'tarjeta.dart';
import 'usuario.dart';

class Tarjetas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tipo => text()();
  TextColumn get nombre => text()();
  TextColumn get banco => text()();
  TextColumn get bandera => text()();
  TextColumn get color => text()();
  RealColumn get limite => real().nullable()();
  IntColumn get usuarioId => integer().references(Usuarios, #id)();
  IntColumn get fechaCierre => integer().nullable()();
}
