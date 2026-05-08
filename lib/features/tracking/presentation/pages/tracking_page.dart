import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/tracking_provider.dart';
import '../../domain/models/tracking_state.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/localization/app_translations.dart';

class TrackingPage extends ConsumerWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackingProvider);
    final notifier = ref.read(trackingProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final lang = settings.language;

    String t(String key) => AppTranslations.translate(lang, key);

    return Scaffold(
      body: Stack(
        children: [
          // Background Map
          _buildMap(state),
          
          // Header overlay
          Positioned(
            top: 40,
            left: 24,
            right: 24,
            child: _buildHeader(context, state),
          ),

          // Bottom Stats
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildStatsPanel(context, state, notifier, t),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(TrackingState state) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: state.lastPosition ?? const LatLng(-6.200000, 106.816666),
        zoom: 16,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapType: MapType.normal, // Gunakan normal, style dark bisa via JSON
      polylines: {
        Polyline(
          polylineId: const PolylineId("route"),
          points: state.route,
          color: AppColors.primary,
          width: 5,
        ),
      },
      onMapCreated: (controller) {
        // Apply dark mode style if needed
      },
    );
  }

  Widget _buildHeader(BuildContext context, TrackingState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 22),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: state.status == TrackingStatus.running
                      ? AppColors.primary
                      : state.status == TrackingStatus.paused
                          ? Colors.amber
                          : AppColors.textSecondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                state.status.name.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsPanel(BuildContext context, TrackingState state, TrackingNotifier notifier, Function(String) t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMainMetric(state),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(t('pace'), state.formattedPace, FontAwesomeIcons.bolt),
              _buildMetricItem(t('time'), state.formattedDuration, FontAwesomeIcons.clock),
              _buildMetricItem(t('kcal'), "420", FontAwesomeIcons.fire),
            ],
          ),
          const SizedBox(height: 40),
          _buildControls(context, state, notifier, t),
        ],
      ),
    );
  }

  Widget _buildMainMetric(TrackingState state) {
    return Column(
      children: [
        FaIcon(state.activityType.icon, color: AppColors.primary, size: 32),
        const SizedBox(height: 16),
        Text(
          state.formattedDistance.split(' ')[0],
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
            height: 1,
          ),
        ),
        Text(
          state.formattedDistance.split(' ')[1].toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        FaIcon(icon, color: AppColors.textSecondary.withOpacity(0.5), size: 14),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, TrackingState state, TrackingNotifier notifier, Function(String) t) {
    if (state.status == TrackingStatus.idle || state.status == TrackingStatus.stopped) {
      return _buildControlButton(
        icon: Icons.play_arrow_rounded,
        color: AppColors.primary,
        onTap: () => notifier.startTracking(),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state.status == TrackingStatus.running)
          _buildControlButton(
            icon: Icons.pause_rounded,
            color: AppColors.secondary,
            onTap: () => notifier.pauseTracking(),
          )
        else
          _buildControlButton(
            icon: Icons.play_arrow_rounded,
            color: AppColors.primary,
            onTap: () => notifier.resumeTracking(),
          ),
        const SizedBox(width: 32),
        _buildControlButton(
          icon: Icons.stop_rounded,
          color: AppColors.accent,
          onTap: () {
            notifier.stopTracking();
            _showSummaryDialog(context, state, notifier, t);
          },
          isLarge: false,
        ),
      ],
    );
  }

  void _showSummaryDialog(BuildContext context, TrackingState state, TrackingNotifier notifier, Function(String) t) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(t('run_completed'), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.trophy, color: Colors.amber, size: 48),
            const SizedBox(height: 24),
            _buildSummaryRow(t('distance'), state.formattedDistance),
            const SizedBox(height: 12),
            _buildSummaryRow(t('duration'), state.formattedDuration),
            const SizedBox(height: 12),
            _buildSummaryRow(t('avg_pace'), state.formattedPace),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              notifier.reset();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit tracking page
            },
            child: Text(t('awesome'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLarge = true,
  }) {
    double size = isLarge ? 80 : 60;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: size * 0.5),
      ),
    );
  }
}
