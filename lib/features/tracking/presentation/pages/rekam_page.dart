import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/tracking_provider.dart';
import '../providers/history_provider.dart';
import 'tracking_page.dart';
import 'heart_rate_page.dart';

class RekamPage extends ConsumerStatefulWidget {
  const RekamPage({super.key});

  @override
  ConsumerState<RekamPage> createState() => _RekamPageState();
}

class _RekamPageState extends ConsumerState<RekamPage> {
  String _selectedTarget = "Bebas"; // Bebas, 1 km, 3 km, 5 km, 10 km
  bool _autoPause = true;
  bool _audioCues = false;
  bool _measureHeartRate = true;

  final Map<String, String> _targetMapEn = {
    "Bebas": "Free",
    "1 km": "1 km",
    "3 km": "3 km",
    "5 km": "5 km",
    "10 km": "10 km",
  };

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingProvider);
    final trackingNotifier = ref.read(trackingProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final lang = settings.language;
    final isIndo = lang == 'Bahasa Indonesia';

    const cyanColor = Color(0xFF00E5FF);
    const greenReady = Color(0xFF00FF7F);
    const darkCard = Color(0xFF141618); // very dark grey card
    const labelColor = Color(0xFF7A828A);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1013), // very dark teal-black bg
      body: Stack(
        children: [
          // Subtle top-left cyan gradient glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [cyanColor.withValues(alpha: 0.05), Colors.transparent],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isIndo ? "Mulai Aktivitas" : "Record Activity",
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A1A14), // Dark greenish bg
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: greenReady,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isIndo ? "GPS READY" : "GPS READY",
                                style: GoogleFonts.inter(
                                  color: greenReady,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),

                    // MAP / LOCATION PREVIEW (Dark sleek style)
                    SizedBox(
                      height: 250,
                      child: Container(
                        width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        color: Colors.black,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: trackingState.lastPosition ?? const LatLng(-6.200000, 106.816666),
                              initialZoom: 16,
                              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                                subdomains: const ['a', 'b', 'c', 'd'],
                                userAgentPackageName: 'com.runity.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  if (trackingState.lastPosition != null)
                                    Marker(
                                      point: trackingState.lastPosition!,
                                      width: 14,
                                      height: 14,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: cyanColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: cyanColor.withValues(alpha: 0.5),
                                              blurRadius: 10,
                                              spreadRadius: 3,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            ],
                          ),
                          // Dark gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                          // Location text
                          Positioned(
                            bottom: 16,
                            left: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isIndo ? "LOKASI SAAT INI" : "CURRENT LOCATION",
                                  style: GoogleFonts.inter(
                                    color: cyanColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isIndo ? "Sudirman, Jakarta" : "Shibuya Crossing, Tokyo", // Hardcoded to match vibe, or could use real geocoding
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),

                    const SizedBox(height: 16),

                    // SELECT SPORT
                    Text(
                      isIndo ? "PILIH OLAHRAGA" : "SELECT SPORT",
                      style: GoogleFonts.inter(color: labelColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: SportType.values.map((type) {
                        final isSelected = trackingState.activityType == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => trackingNotifier.setActivityType(type),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? cyanColor.withValues(alpha: 0.05) : darkCard,
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected ? Border.all(color: cyanColor, width: 1.5) : null,
                                boxShadow: isSelected ? [BoxShadow(color: cyanColor.withValues(alpha: 0.2), blurRadius: 10)] : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FaIcon(
                                    type.icon,
                                    color: isSelected ? cyanColor : Colors.white54,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    type.name,
                                    style: GoogleFonts.inter(
                                      color: isSelected ? cyanColor : Colors.white54,
                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                      fontSize: 9,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // ACTIVITY TARGET
                    Text(
                      isIndo ? "TARGET AKTIVITAS" : "ACTIVITY TARGET",
                      style: GoogleFonts.inter(color: labelColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ["Bebas", "1 km", "3 km", "5 km"].map((target) {
                        final isSelected = _selectedTarget == target;
                        final label = isIndo ? target : (_targetMapEn[target] ?? target);

                        return GestureDetector(
                          onTap: () => setState(() => _selectedTarget = target),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: isSelected ? cyanColor : darkCard,
                              shape: BoxShape.circle,
                              boxShadow: isSelected ? [BoxShadow(color: cyanColor.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 2)] : null,
                            ),
                            child: Center(
                              child: Text(
                                label.replaceAll(" ", "\n"),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: isSelected ? Colors.black : Colors.white54,
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                  fontSize: 13,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // QUICK SETTINGS
                    Text(
                      isIndo ? "PENGATURAN CEPAT" : "QUICK SETTINGS",
                      style: GoogleFonts.inter(color: labelColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 16),
                    
                    Column(
                      children: [
                        _buildSettingPill(
                          icon: Icons.adjust_rounded,
                          iconColor: cyanColor,
                          title: isIndo ? "Jeda Otomatis" : "Auto-Pause",
                          value: _autoPause,
                          onChanged: (val) => setState(() => _autoPause = val),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingPill(
                          icon: Icons.volume_up_outlined,
                          iconColor: cyanColor,
                          title: isIndo ? "Panduan Suara" : "Voice Audio Cues",
                          value: _audioCues,
                          onChanged: (val) => setState(() => _audioCues = val),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingPill(
                          icon: Icons.favorite_border_rounded,
                          iconColor: cyanColor,
                          title: isIndo ? "Detak Jantung" : "Measure Heart Rate",
                          value: _measureHeartRate,
                          onChanged: (val) {
                            setState(() => _measureHeartRate = val);
                            if (val) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const HeartRatePage()),
                              ).then((bpm) {
                                if (bpm != null && bpm is int) {
                                  ref.read(trackingProvider.notifier).setHeartRate(bpm);
                                  // Keep the switch ON to indicate successful capture
                                } else {
                                  setState(() => _measureHeartRate = false);
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    const Spacer(),

                    // GIANT PLAY BUTTON
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(trackingProvider.notifier).setSettings(
                            autoPause: _autoPause,
                            audioCues: _audioCues,
                          );
                          ref.read(trackingProvider.notifier).startTracking();
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const TrackingPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                var begin = const Offset(0.0, 1.0);
                                var end = Offset.zero;
                                var curve = Curves.easeInOutQuart;
                                var tweet = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: animation.drive(tweet),
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                                        CurvedAnimation(parent: animation, curve: curve),
                                      ),
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 700),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cyanColor.withValues(alpha: 0.1),
                              ),
                            ).animate(onPlay: (c) => c.repeat(reverse: true))
                             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds, curve: Curves.easeInOut),
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cyanColor,
                                boxShadow: [
                                  BoxShadow(color: cyanColor.withValues(alpha: 0.5), blurRadius: 24, spreadRadius: 4),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.play_arrow_rounded, color: Colors.black, size: 48),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.easeOutBack, duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingPill({required IconData icon, required Color iconColor, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141618),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          // Custom switch look
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF00E5FF),
            inactiveTrackColor: Colors.black,
            inactiveThumbColor: Colors.white,
            trackOutlineColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
