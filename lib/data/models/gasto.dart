import 'package:drift/drift.dart';
import 'tarjeta.dart';
import 'usuario.dart';

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
