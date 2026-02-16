import 'package:drift/drift.dart';

class Usuarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text()();
}
