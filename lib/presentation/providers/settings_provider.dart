import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool isDarkMode;
  final bool onboardingCompleted;
  final bool bloqueoEdicion;

  SettingsState({
    this.isDarkMode = false,
    this.onboardingCompleted = false,
    this.bloqueoEdicion = false,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? onboardingCompleted,
    bool? bloqueoEdicion,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      bloqueoEdicion: bloqueoEdicion ?? this.bloqueoEdicion,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences? _prefs;

  SettingsNotifier(this._prefs) : super(SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    if (_prefs != null) {
      state = SettingsState(
        isDarkMode: _prefs!.getBool('isDarkMode') ?? false,
        onboardingCompleted: _prefs!.getBool('onboardingCompleted') ?? false,
        bloqueoEdicion: _prefs!.getBool('bloqueoEdicion') ?? false,
      );
    }
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool('isDarkMode', value);
    state = state.copyWith(isDarkMode: value);
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs?.setBool('onboardingCompleted', value);
    state = state.copyWith(onboardingCompleted: value);
  }

  Future<void> setBloqueoEdicion(bool value) async {
    await _prefs?.setBool('bloqueoEdicion', value);
    state = state.copyWith(bloqueoEdicion: value);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(sharedPreferencesProvider));
});

final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).isDarkMode;
});

final onboardingCompletedProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).onboardingCompleted;
});

final bloqueoEdicionProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).bloqueoEdicion;
});
