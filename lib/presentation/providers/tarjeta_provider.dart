import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import 'repository_providers.dart';

class TarjetaState {
  final List<Tarjeta> tarjetas;
  final bool isLoading;
  final String? error;

  TarjetaState({
    this.tarjetas = const [],
    this.isLoading = false,
    this.error,
  });

  TarjetaState copyWith({
    List<Tarjeta>? tarjetas,
    bool? isLoading,
    String? error,
  }) {
    return TarjetaState(
      tarjetas: tarjetas ?? this.tarjetas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TarjetaNotifier extends StateNotifier<TarjetaState> {
  final Ref _ref;

  TarjetaNotifier(this._ref) : super(TarjetaState(isLoading: true)) {
    loadTarjetas();
  }

  Future<void> loadTarjetas() async {
    state = state.copyWith(isLoading: true);
    try {
      final tarjetas = await _ref.read(tarjetaRepositoryProvider).getAll();
      state = state.copyWith(tarjetas: tarjetas, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<int> addTarjeta({
    required String tipo,
    required String nombre,
    required String banco,
    required String nombreTarjeta,
    required String color,
    double? limite,
    required int usuarioId,
    int? fechaCierre,
  }) async {
    try {
      final id = await _ref.read(tarjetaRepositoryProvider).create(
        tipo: tipo,
        nombre: nombre,
        banco: banco,
        nombreTarjeta: nombreTarjeta,
        color: color,
        limite: limite,
        usuarioId: usuarioId,
        fechaCierre: fechaCierre,
      );
      await loadTarjetas();
      return id;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return -1;
    }
  }

  Future<void> updateTarjeta(Tarjeta tarjeta) async {
    try {
      await _ref.read(tarjetaRepositoryProvider).update(tarjeta);
      await loadTarjetas();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTarjeta(int id) async {
    try {
      await _ref.read(tarjetaRepositoryProvider).delete(id);
      await loadTarjetas();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final tarjetaProvider = StateNotifierProvider<TarjetaNotifier, TarjetaState>((ref) {
  return TarjetaNotifier(ref);
});
