import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool darkMode;
  final String units;
  final String language;
  final String gpsAccuracy;
  final bool heartRateConnected;
  final bool biometricEnabled;
  final bool autoSync;
  final String cacheSize;

  SettingsState({
    this.darkMode = true,
    this.units = 'Metric (km)',
    this.language = 'English',
    this.gpsAccuracy = 'High',
    this.heartRateConnected = true,
    this.biometricEnabled = false,
    this.autoSync = true,
    this.cacheSize = '124 MB',
  });

  SettingsState copyWith({
    bool? darkMode,
    String? units,
    String? language,
    String? gpsAccuracy,
    bool? heartRateConnected,
    bool? biometricEnabled,
    bool? autoSync,
    String? cacheSize,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      units: units ?? this.units,
      language: language ?? this.language,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      heartRateConnected: heartRateConnected ?? this.heartRateConnected,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoSync: autoSync ?? this.autoSync,
      cacheSize: cacheSize ?? this.cacheSize,
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

  void toggleHeartRate() => state = state.copyWith(heartRateConnected: !state.heartRateConnected);

  void toggleAutoSync() => state = state.copyWith(autoSync: !state.autoSync);

  void clearCache() => state = state.copyWith(cacheSize: '0 MB');
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
