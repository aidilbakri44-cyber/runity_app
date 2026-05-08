import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../core/localization/app_translations.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final lang = settings.language;

    String t(String key) => AppTranslations.translate(lang, key);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('settings'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(t('app_preferences')),
            _buildSettingTile(
              icon: FontAwesomeIcons.moon,
              title: t('dark_mode'),
              value: settings.darkMode ? "Always On" : "Off",
              onTap: () => notifier.toggleDarkMode(),
            ),
            _buildSettingTile(
              icon: FontAwesomeIcons.ruler,
              title: t('units'),
              value: settings.units,
              onTap: () => _showOptionsDialog(context, t('units'), ["Metric (km)", "Imperial (mi)"], (v) => notifier.setUnits(v)),
            ),
            _buildSettingTile(
              icon: FontAwesomeIcons.globe,
              title: t('language'),
              value: settings.language,
              onTap: () => _showOptionsDialog(context, t('language'), ["English", "Bahasa Indonesia"], (v) => notifier.setLanguage(v)),
            ),
            _buildSettingTile(
              icon: Theme.of(context).platform == TargetPlatform.iOS ? FontAwesomeIcons.faceSmile : FontAwesomeIcons.fingerprint,
              title: t('biometric_auth'),
              value: (settings.biometricEnabled == true) 
                ? (Theme.of(context).platform == TargetPlatform.iOS ? "FaceID On" : "Fingerprint On") 
                : "Off",
              onTap: () => _simulateBiometricAuth(context, notifier),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(t('device_sensors')),
            _buildSettingTile(
              icon: FontAwesomeIcons.locationCrosshairs,
              title: t('gps_accuracy'),
              value: settings.gpsAccuracy,
              onTap: () => _showOptionsDialog(context, t('gps_accuracy'), ["High", "Balanced", "Power Saving"], (v) => notifier.setGpsAccuracy(v)),
            ),
            _buildSettingTile(
              icon: FontAwesomeIcons.heartPulse,
              title: t('heart_rate'),
              value: settings.heartRateConnected ? "Connected" : "Disconnected",
              onTap: () {},
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(t('account')),
            _buildSettingTile(
              icon: FontAwesomeIcons.cloudArrowUp,
              title: t('auto_sync'),
              value: "Enabled",
              onTap: () {},
            ),
            _buildSettingTile(
              icon: FontAwesomeIcons.trashCan,
              title: t('clear_cache'),
              value: "124 MB",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 16),
              ...options.map((opt) => ListTile(
                title: Text(opt, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  onSelect(opt);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          child: ListTile(
            leading: FaIcon(icon, color: AppColors.textSecondary, size: 18),
            title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 16, color: Colors.white24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _simulateBiometricAuth(BuildContext context, SettingsNotifier notifier) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final authMethod = isIOS ? "FaceID" : "Fingerprint";
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            FaIcon(
              isIOS ? FontAwesomeIcons.faceSmile : FontAwesomeIcons.fingerprint, 
              size: 64, 
              color: AppColors.primary
            ),
            const SizedBox(height: 24),
            Text(
              "Authenticating with $authMethod...",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    // Simulate delay
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pop(context);
        notifier.toggleBiometric();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$authMethod Security Updated!"),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    });
  }
}
