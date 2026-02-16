import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database_helper.dart';
import '../../data/repositories/repositories.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) {
  return UsuarioRepository();
});

final tarjetaRepositoryProvider = Provider<TarjetaRepository>((ref) {
  return TarjetaRepository();
});

final gastoRepositoryProvider = Provider<GastoRepository>((ref) {
  return GastoRepository();
});
