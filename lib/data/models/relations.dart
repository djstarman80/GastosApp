import 'package:drift/drift.dart';
import '../models/models.dart';

class GastosWithRelations {
  final Gasto gasto;
  final Tarjeta? tarjeta;
  final Usuario? usuario;

  GastosWithRelations({
    required this.gasto,
    this.tarjeta,
    this.usuario,
  });
}

class TarjetasWithRelations {
  final Tarjeta tarjeta;
  final Usuario? usuario;

  TarjetasWithRelations({
    required this.tarjeta,
    this.usuario,
  });
}
