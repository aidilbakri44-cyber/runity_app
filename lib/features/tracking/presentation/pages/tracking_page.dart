import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/tracking_provider.dart';
import '../../domain/models/tracking_state.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/localization/app_translations.dart';
import 'save_activity_page.dart';

class TrackingPage extends ConsumerStatefulWidget {
  const TrackingPage({super.key});

  @override
  ConsumerState<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends ConsumerState<TrackingPage> {
  bool _isMapExpanded = false;
  final MapController _mapController = MapController();

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

  @override
  Widget build(BuildContext context) {
    // Listen for location changes to auto-center the map
    ref.listen<TrackingState>(trackingProvider, (previous, next) {
      if (next.lastPosition != null && next.lastPosition != previous?.lastPosition) {
        _mapController.move(next.lastPosition!, _mapController.camera.zoom);
      }
    });

    final state = ref.watch(trackingProvider);
    final notifier = ref.read(trackingProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final lang = settings.language;
    final isIndo = lang == 'Bahasa Indonesia';

    String t(String key) => AppTranslations.translate(lang, key);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Map
          _buildMap(state),
          
          // Header overlay
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: _buildHeader(context, state)
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.2, end: 0),
          ),

          // TOP PILLS (GPS LOCKED, HUD SYNCED)
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPill("GPS:\nLOCKED", const Color(0xFFC6FF00), true),
                const SizedBox(width: 12),
                _buildPill("HUD\nSYNCED", Colors.white38, false),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ),

          // Main Bottom Panel (Dynamic Size)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuart,
            bottom: _isMapExpanded ? -400 : -20, // Hides bottom panel when expanded
            left: 0,
            right: 0,
            child: _buildPortraitLayout(context, state, notifier, isIndo),
          ),
          
          // Small panel when expanded
          if (_isMapExpanded)
             AnimatedPositioned(
               duration: const Duration(milliseconds: 600),
               curve: Curves.easeInOutQuart,
               bottom: 24,
               left: 20,
               right: 20,
               child: _buildLandscapeLayout(state, notifier, t),
             ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, Color iconColor, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
              boxShadow: isActive ? [BoxShadow(color: iconColor.withOpacity(0.6), blurRadius: 4, spreadRadius: 1)] : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: isActive ? iconColor : Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              height: 1.1,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(TrackingState state) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: state.lastPosition ?? const LatLng(-6.200000, 106.816666),
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.runity.app',
        ),
        if (state.route.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: state.route,
                color: const Color(0xFF00E5FF),
                strokeWidth: 6,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (state.lastPosition != null)
              Marker(
                point: state.lastPosition!,
                width: 16,
                height: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 4,
                      )
                    ],
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
        // RUNITY logo (acts as back to dashboard)
        GestureDetector(
          onTap: () {
            ref.read(trackingProvider.notifier).stopTracking(saveToHistory: false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SaveActivityPage()),
            );
          },
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                  color: const Color(0xFF0D1B2A),
                ),
                child: const Center(
                  child: Icon(Icons.blur_on, color: Color(0xFF00E5FF), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "RUNITY",
                style: GoogleFonts.lexendDeca(
                  color: const Color(0xFF00E5FF),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        
        // Bell & Full Map
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() => _isMapExpanded = !_isMapExpanded),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isMapExpanded ? const Color(0xFF00E5FF) : Colors.white.withOpacity(0.1)),
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isMapExpanded ? Icons.fullscreen_exit : Icons.map_outlined, 
                      color: _isMapExpanded ? const Color(0xFF00E5FF) : Colors.white, 
                      size: 14
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isMapExpanded ? "SHRINK" : "FULL MAP",
                      style: GoogleFonts.inter(
                        color: _isMapExpanded ? const Color(0xFF00E5FF) : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(BuildContext context, TrackingState state, TrackingNotifier notifier, bool isIndo) {
    double distKm = state.distance / 1000;
    String distStr = distKm.toStringAsFixed(2);
    String timeStr = formatDurationAlwaysHours(state.duration);
    String paceStr = formatPaceColon(state.currentPace);
    final isRunning = state.status == TrackingStatus.running;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      decoration: const BoxDecoration(
        color: Color(0xFF101214), // Very dark frosted-like solid
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Distance label
          Text(
            isIndo ? "JARAK (KM)" : "DISTANCE (KM)",
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          
          // 2. Distance value
          Text(
            distStr,
            style: GoogleFonts.inter(
              color: const Color(0xFF00E5FF),
              fontSize: 84,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -2,
            ),
          ),

          const SizedBox(height: 24),

          // 3. Metrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetricCol(isIndo ? "PACE" : "PACE", paceStr, null),
              Container(width: 1, height: 30, color: Colors.white10),
              _buildMetricCol(isIndo ? "WAKTU" : "TIME", timeStr, null),
              Container(width: 1, height: 30, color: Colors.white10),
              _buildMetricCol(isIndo ? "DETAK" : "HEART", state.heartRate > 0 ? "${state.heartRate}" : "--", const Color(0xFFFF80AB)),
            ],
          ),

          const SizedBox(height: 40),

          // 4. Controls Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stop square
              GestureDetector(
                onTap: () {
                  notifier.stopTracking(saveToHistory: false);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SaveActivityPage()),
                  );
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFF7043).withOpacity(0.3), width: 1.5),
                    color: Colors.transparent,
                  ),
                  child: const Center(
                    child: Icon(Icons.stop_rounded, color: Color(0xFFFF7043), size: 24),
                  ),
                ),
              ),

              // Pause/Resume Pill
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isRunning) {
                      notifier.pauseTracking();
                    } else {
                      notifier.resumeTracking();
                    }
                  },
                  child: Container(
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isRunning 
                              ? (isIndo ? "JEDA LARI" : "PAUSE RUN")
                              : (isIndo ? "LANJUTKAN" : "RESUME RUN"),
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate(target: isRunning ? 1 : 0)
               .scale(begin: const Offset(1,1), end: const Offset(1.02, 1.02), duration: 200.ms),

              // Share button
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10, width: 1.5),
                  color: Colors.transparent,
                ),
                child: const Center(
                  child: Icon(Icons.share_outlined, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(TrackingState state, TrackingNotifier notifier, Function(String) t) {
    // A mini transparent floating pill when the map is expanded
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              FaIcon(state.activityType.icon, color: const Color(0xFF00E5FF), size: 20),
              const SizedBox(width: 12),
              Text(
                state.formattedDistance,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(width: 1, height: 24, color: Colors.white10),
          Text(
            formatDurationAlwaysHours(state.duration),
            style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Container(width: 1, height: 24, color: Colors.white10),
          Row(
            children: [
              GestureDetector(
                onTap: () => state.status == TrackingStatus.running ? notifier.pauseTracking() : notifier.resumeTracking(),
                child: Icon(state.status == TrackingStatus.running ? Icons.pause_rounded : Icons.play_arrow_rounded, color: const Color(0xFF00E5FF), size: 28),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  notifier.stopTracking(saveToHistory: false);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SaveActivityPage()));
                },
                child: const Icon(Icons.stop_rounded, color: Color(0xFFFF7043), size: 24),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, Color? heartColor) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (heartColor != null)
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(Icons.favorite_border, color: heartColor, size: 12),
              ),
            Text(
              value,
              style: GoogleFonts.inter(
                color: heartColor ?? Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

}
