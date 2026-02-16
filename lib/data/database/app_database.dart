import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Usuarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
}

class Tarjetas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tipo => text()();
  TextColumn get nombre => text()();
  TextColumn get banco => text()();
  TextColumn get nombreTarjeta => text()();
  TextColumn get color => text()();
  RealColumn get limite => real().nullable()();
  IntColumn get usuarioId => integer().references(Usuarios, #id)();
  IntColumn get fechaCierre => integer().nullable()();
}

class Gastos extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get monto => real()();
  TextColumn get descripcion => text()();
  IntColumn get tarjetaId => integer().references(Tarjetas, #id)();
  IntColumn get usuarioId => integer().references(Usuarios, #id)();
  IntColumn get cuotas => integer().nullable()();
  BoolColumn get esRecurrente => boolean().withDefault(const Constant(false))();
  IntColumn get fecha => integer()();
  IntColumn get fechaPago => integer().nullable()();
  BoolColumn get pagado => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Usuarios, Tarjetas, Gastos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'gastos.db'));
    return NativeDatabase.createInBackground(file);
  });
}
