import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import 'repository_providers.dart';

class GastoState {
  final List<Gasto> gastos;
  final bool isLoading;
  final String? error;
  final double totalGastos;

  GastoState({
    this.gastos = const [],
    this.isLoading = false,
    this.error,
    this.totalGastos = 0.0,
  });

  GastoState copyWith({
    List<Gasto>? gastos,
    bool? isLoading,
    String? error,
    double? totalGastos,
  }) {
    return GastoState(
      gastos: gastos ?? this.gastos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalGastos: totalGastos ?? this.totalGastos,
    );
  }
}

class GastoNotifier extends StateNotifier<GastoState> {
  final Ref _ref;

  GastoNotifier(this._ref) : super(GastoState(isLoading: true)) {
    loadGastos();
  }

  Future<void> loadGastos() async {
    state = state.copyWith(isLoading: true);
    try {
      final gastos = await _ref.read(gastoRepositoryProvider).getAll();
      double total = 0;
      for (final g in gastos) total += g.monto;
      state = state.copyWith(gastos: gastos, totalGastos: total, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<int> addGasto({
    required double monto,
    required String descripcion,
    required int tarjetaId,
    required int usuarioId,
    int? cuotas,
    bool esRecurrente = false,
    required int fecha,
    int? fechaPago,
    bool pagado = false,
  }) async {
    try {
      final id = await _ref.read(gastoRepositoryProvider).create(
        monto: monto,
        descripcion: descripcion,
        tarjetaId: tarjetaId,
        usuarioId: usuarioId,
        cuotas: cuotas,
        esRecurrente: esRecurrente,
        fecha: fecha,
        fechaPago: fechaPago,
        pagado: pagado,
      );
      await loadGastos();
      return id;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return -1;
    }
  }

  Future<void> updateGasto(Gasto gasto) async {
    try {
      await _ref.read(gastoRepositoryProvider).update(gasto);
      await loadGastos();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteGasto(int id) async {
    try {
      await _ref.read(gastoRepositoryProvider).delete(id);
      await loadGastos();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final gastoProvider = StateNotifierProvider<GastoNotifier, GastoState>((ref) {
  return GastoNotifier(ref);
});
