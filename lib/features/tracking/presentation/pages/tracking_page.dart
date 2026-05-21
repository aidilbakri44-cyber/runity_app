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
  bool _showMap = false; // Default to Metrics Dashboard view

  @override
  void initState() {
    super.initState();
  }

  String formatDurationAlwaysHours(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String formatPaceColon(double pace) {
    if (pace == 0 || pace.isInfinite || pace.isNaN) return "-:--";
    int minutes = pace.toInt();
    int seconds = ((pace - minutes) * 60).toInt();
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  List<Map<String, dynamic>> getSplits(double distanceKm, double avgPace) {
    int numFullKms = distanceKm.toInt();
    List<Map<String, dynamic>> splits = [];
    
    if (distanceKm <= 0) {
      return [];
    }
    
    for (int i = 1; i <= numFullKms; i++) {
      double variation = (i % 2 == 0 ? 0.2 : -0.15) * (1.0 + (i % 3) * 0.1);
      double splitPace = avgPace + variation;
      if (splitPace < 3.0) splitPace = 3.12;
      splits.add({
        "km": i,
        "pace": splitPace,
      });
    }
    
    double remainingDist = distanceKm - numFullKms;
    if (remainingDist > 0.05 || splits.isEmpty) {
      splits.add({
        "km": numFullKms + 1,
        "pace": avgPace > 0 ? avgPace : 5.28,
      });
    }
    
    return splits;
  }

  Widget _buildSplitsChart(double distanceMeters, double avgPace, bool isIndo) {
    double distanceKm = distanceMeters / 1000;
    List<Map<String, dynamic>> splits = getSplits(distanceKm, avgPace);

    if (splits.isEmpty) {
      splits = [{"km": 1, "pace": avgPace > 0 ? avgPace : 5.28}];
    }
    if (splits.length > 4) {
      splits = splits.sublist(splits.length - 4);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: splits.asMap().entries.map((entry) {
        final i = entry.key;
        final split = entry.value;
        final paceVal = split["pace"] as double;
        final isCurrent = i == splits.length - 1;

        String paceStr = formatPaceColon(paceVal);
        double clampedPace = paceVal.clamp(3.0, 10.0);
        double height = 22.0 + (62.0 * (10.0 - clampedPace) / 7.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Glow shadow under current bar
              Container(
                width: 28,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: isCurrent
                        ? [AppColors.secondary, AppColors.primary]
                        : [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.1),
                          ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.6),
                            blurRadius: 12,
                            offset: const Offset(0, -2),
                          ),
                        ]
                      : [],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                paceStr,
                style: TextStyle(
                  color: isCurrent ? AppColors.primary : Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsDashboard(BuildContext context, TrackingState state, TrackingNotifier notifier, bool isIndo) {
    double distKm = state.distance / 1000;
    String distStr = distKm.toStringAsFixed(2);
    if (isIndo) distStr = distStr.replaceAll('.', ',');

    String timeStr = formatDurationAlwaysHours(state.duration);
    String paceStr = formatPaceColon(state.currentPace);
    final isRunning = state.status == TrackingStatus.running;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─── Ambient neon blobs ───
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4.seconds, curve: Curves.easeInOut),
          ),
          Positioned(
            bottom: 60,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 5.seconds, curve: Curves.easeInOut),
          ),

          // ─── Main content ───
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // ── Header row ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (isRunning) notifier.pauseTracking();
                          _showSummaryDialog(context, state, notifier, (k) => k);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Icon(Icons.close, color: Colors.white54, size: 18),
                        ),
                      ),
                      // Activity pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ).animate(onPlay: (c) => c.repeat(reverse: true))
                             .scale(begin: const Offset(0.6, 0.6), end: const Offset(1.3, 1.3), duration: 800.ms),
                            const SizedBox(width: 8),
                            Text(
                              state.activityType.name.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),

                  const Spacer(),

                  // ── WAKTU ──
                  Column(
                    children: [
                      Text(
                        isIndo ? "WAKTU" : "TIME",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 62,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── Neon Divider ──
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, AppColors.primary.withOpacity(0.5)],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary.withOpacity(0.5), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── PACE SPLIT ──
                  Column(
                    children: [
                      Text(
                        isIndo ? "PACE SPLIT RATA2" : "AVG SPLIT PACE",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        paceStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 104,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "/KM",
                        style: TextStyle(
                          color: AppColors.primary.withOpacity(0.6),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── Neon Divider ──
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, AppColors.secondary.withOpacity(0.5)],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.secondary.withOpacity(0.5), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── Bottom row: Splits + Jarak ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Split Bar Chart
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isIndo ? "PACE SPLIT" : "SPLIT PACE",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSplitsChart(state.distance, state.currentPace, isIndo),
                        ],
                      ),

                      // JARAK (Distance)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isIndo ? "JARAK" : "DISTANCE",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                distStr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  "KM",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── Controls ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Map toggle
                        GestureDetector(
                          onTap: () => setState(() => _showMap = true),
                          child: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Icon(Icons.map_outlined, color: Colors.white54, size: 20),
                          ),
                        ),

                        const SizedBox(width: 24),

                        // Main Pause/Play button — large neon glowing
                        GestureDetector(
                          onTap: () => isRunning
                              ? notifier.pauseTracking()
                              : notifier.resumeTracking(),
                          child: Container(
                            width: 88, height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF5500), Color(0xFFFF2255)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF4422).withOpacity(0.5),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                         .scale(begin: const Offset(1, 1), end: const Offset(1.03, 1.03), duration: 1.2.seconds, curve: Curves.easeInOut),

                        const SizedBox(width: 24),

                        // Stop button (always visible when paused, hidden when running)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: state.status == TrackingStatus.paused ? 1.0 : 0.2,
                          child: GestureDetector(
                            onTap: state.status == TrackingStatus.paused ? () {
                              notifier.stopTracking();
                              _showSummaryDialog(context, state, notifier, (k) => k);
                            } : null,
                            child: Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accent.withOpacity(0.15),
                                border: Border.all(color: AppColors.accent.withOpacity(0.6), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.3),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.stop_rounded, color: AppColors.accent, size: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackingProvider);
    final notifier = ref.read(trackingProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final lang = settings.language;
    final isIndo = lang == 'Bahasa Indonesia';

    String t(String key) => AppTranslations.translate(lang, key);

    if (!_showMap) {
      return _buildMetricsDashboard(context, state, notifier, isIndo);
    }

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
        GestureDetector(
          onTap: () {
            setState(() {
              _showMap = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary, width: 1.5),
            ),
            child: const Row(
              children: [
                Icon(Icons.dashboard_outlined, color: AppColors.secondary, size: 16),
                SizedBox(width: 8),
                Text(
                  "DASHBOARD",
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
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
