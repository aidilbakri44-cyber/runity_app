import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool darkMode;
  final String units;
  final String language;
  final String gpsAccuracy;
  final bool heartRateConnected;
  final bool biometricEnabled;

  SettingsState({
    this.darkMode = true,
    this.units = 'Metric (km)',
    this.language = 'English',
    this.gpsAccuracy = 'High',
    this.heartRateConnected = true,
    this.biometricEnabled = false,
  });

  SettingsState copyWith({
    bool? darkMode,
    String? units,
    String? language,
    String? gpsAccuracy,
    bool? heartRateConnected,
    bool? biometricEnabled,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      units: units ?? this.units,
      language: language ?? this.language,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      heartRateConnected: heartRateConnected ?? this.heartRateConnected,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());

  void toggleDarkMode() => state = state.copyWith(darkMode: !state.darkMode);
  
  void toggleBiometric() => state = state.copyWith(biometricEnabled: !state.biometricEnabled);
  
  void setUnits(String units) => state = state.copyWith(units: units);
  
  void setLanguage(String language) => state = state.copyWith(language: language);

  void setGpsAccuracy(String accuracy) => state = state.copyWith(gpsAccuracy: accuracy);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
