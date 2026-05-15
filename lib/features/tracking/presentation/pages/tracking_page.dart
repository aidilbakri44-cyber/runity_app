import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/tracking_provider.dart';
import '../../domain/models/tracking_state.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/localization/app_translations.dart';

class TrackingPage extends ConsumerStatefulWidget {
  const TrackingPage({super.key});

  @override
  ConsumerState<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends ConsumerState<TrackingPage> {
  bool _isMapExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackingProvider);
    final notifier = ref.read(trackingProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final lang = settings.language;

    String t(String key) => AppTranslations.translate(lang, key);

    return Scaffold(
      body: Stack(
        children: [
          // Background OpenStreetMap
          _buildMap(state),
          
          // Header overlay
          Positioned(
            top: 40,
            left: 24,
            right: 24,
            child: _buildHeader(context, state)
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.2, end: 0),
          ),

          // Main Bottom Panel (Dynamic Size)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuart,
            bottom: 24,
            left: 20,
            right: 20,
            child: _buildDynamicPanel(context, state, notifier, t),
          ),

          // Map Toggle Button
          Positioned(
            right: 24,
            bottom: _isMapExpanded ? 130 : 420,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutQuart,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isMapExpanded = !_isMapExpanded;
                  });
                },
                mini: _isMapExpanded,
                backgroundColor: _isMapExpanded ? AppColors.primary : Colors.black.withOpacity(0.7),
                foregroundColor: _isMapExpanded ? Colors.black : Colors.white,
                child: Icon(_isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(TrackingState state) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: state.lastPosition ?? const LatLng(-6.200000, 106.816666),
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.runity.app',
        ),
        if (state.route.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: state.route,
                color: AppColors.primary,
                strokeWidth: 5,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (state.lastPosition != null)
              Marker(
                point: state.lastPosition!,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.navigation, color: Colors.white, size: 20),
                  ),
                ),
              ),
          ],
        ),
      ],
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
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: state.status == TrackingStatus.running ? AppColors.primary : Colors.amber,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                state.status.name.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicPanel(BuildContext context, TrackingState state, TrackingNotifier notifier, Function(String) t) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutQuart,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: _isMapExpanded ? 12 : 24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: _isMapExpanded 
          ? _buildLandscapeLayout(state, notifier, t)
          : _buildPortraitLayout(context, state, notifier, t),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, TrackingState state, TrackingNotifier notifier, Function(String) t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMainMetric(state),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetricItem(t('pace'), state.formattedPace, FontAwesomeIcons.bolt),
            _buildMetricItem(t('time'), state.formattedDuration, FontAwesomeIcons.clock),
            _buildMetricItem(t('kcal'), "420", FontAwesomeIcons.fire),
          ],
        ),
        const SizedBox(height: 24),
        _buildControls(context, state, notifier, t, false),
      ],
    );
  }

  Widget _buildLandscapeLayout(TrackingState state, TrackingNotifier notifier, Function(String) t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FaIcon(state.activityType.icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              state.formattedDistance,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Container(width: 1, height: 24, color: Colors.white10),
        Text(
          state.formattedDuration,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(width: 1, height: 24, color: Colors.white10),
        _buildControls(context, state, notifier, t, true),
      ],
    );
  }

  Widget _buildMainMetric(TrackingState state) {
    return Column(
      children: [
        FaIcon(state.activityType.icon, color: AppColors.primary, size: 32),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              state.formattedDistance.split(' ')[0],
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, height: 1),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                state.formattedDistance.split(' ')[1].toUpperCase(),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        FaIcon(icon, color: AppColors.textSecondary.withOpacity(0.5), size: 14),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildControls(BuildContext context, TrackingState state, TrackingNotifier notifier, Function(String) t, bool isSmall) {
    final size = isSmall ? 40.0 : 70.0;
    final iconSize = isSmall ? 20.0 : 30.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => state.status == TrackingStatus.running ? notifier.pauseTracking() : notifier.resumeTracking(),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: state.status == TrackingStatus.running ? AppColors.secondary : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(state.status == TrackingStatus.running ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.black, size: iconSize),
          ),
        ),
        if (!isSmall) const SizedBox(width: 24),
        if (isSmall) const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            notifier.stopTracking();
            _showSummaryDialog(context, state, notifier, t);
          },
          child: Container(
            width: isSmall ? 40 : 60,
            height: isSmall ? 40 : 60,
            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            child: Icon(Icons.stop_rounded, color: Colors.black, size: isSmall ? 20 : 24),
          ),
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t('distance')), Text(state.formattedDistance, style: const TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t('duration')), Text(state.formattedDuration, style: const TextStyle(fontWeight: FontWeight.bold))]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              notifier.reset();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(t('awesome'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
