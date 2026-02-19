import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/repositories.dart';

final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) {
  return UsuarioRepository();
});

final tarjetaRepositoryProvider = Provider<TarjetaRepository>((ref) {
  return TarjetaRepository();
});

final gastoRepositoryProvider = Provider<GastoRepository>((ref) {
  return GastoRepository();
});
