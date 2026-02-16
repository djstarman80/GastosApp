import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import 'repository_providers.dart';

class UsuarioState {
  final List<Usuario> usuarios;
  final bool isLoading;
  final String? error;

  UsuarioState({
    this.usuarios = const [],
    this.isLoading = false,
    this.error,
  });

  UsuarioState copyWith({
    List<Usuario>? usuarios,
    bool? isLoading,
    String? error,
  }) {
    return UsuarioState(
      usuarios: usuarios ?? this.usuarios,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UsuarioNotifier extends StateNotifier<UsuarioState> {
  final Ref _ref;

  UsuarioNotifier(this._ref) : super(UsuarioState(isLoading: true)) {
    loadUsuarios();
  }

  Future<void> loadUsuarios() async {
    state = state.copyWith(isLoading: true);
    try {
      final usuarios = await _ref.read(usuarioRepositoryProvider).getAll();
      state = state.copyWith(usuarios: usuarios, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addUsuario(String nombre) async {
    try {
      await _ref.read(usuarioRepositoryProvider).create(nombre);
      await loadUsuarios();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateUsuario(Usuario usuario) async {
    try {
      await _ref.read(usuarioRepositoryProvider).update(usuario);
      await loadUsuarios();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteUsuario(int id) async {
    try {
      await _ref.read(usuarioRepositoryProvider).delete(id);
      await loadUsuarios();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final usuarioProvider = StateNotifierProvider<UsuarioNotifier, UsuarioState>((ref) {
  return UsuarioNotifier(ref);
});

final selectedUsuarioIdProvider = StateProvider<int?>((ref) => null);
