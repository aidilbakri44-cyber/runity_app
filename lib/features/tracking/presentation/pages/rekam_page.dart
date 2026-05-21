import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/localization/app_translations.dart';
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
  bool _audioCues = true;
  bool _autoPause = false;
  bool _measureHeartRate = false;

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).blur(begin: const Offset(80, 80), end: const Offset(100, 100), duration: 5.seconds),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title / GPS Status row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isIndo ? "Mulai Aktivitas" : "Record Activity",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      // GPS status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(0.7, 0.7), end: const Offset(1.3, 1.3), duration: 800.ms).then().fadeOut(),
                            const SizedBox(width: 8),
                            Text(
                              isIndo ? "GPS Siap" : "GPS Ready",
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 24),

                  // Map Preview
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: trackingState.lastPosition ?? const LatLng(-6.200000, 106.816666),
                            initialZoom: 15,
                            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.runity.app',
                            ),
                            if (trackingState.lastPosition != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: trackingState.lastPosition!,
                                    width: 32,
                                    height: 32,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.primary, width: 2),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.location_on, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Text(
                            isIndo ? "Lokasi Awal Anda" : "Your Starting Point",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                  const SizedBox(height: 24),

                  // Sport Type Selection
                  Text(
                    isIndo ? "PILIH OLAHRAGA" : "SELECT SPORT",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 12),
                  Row(
                    children: SportType.values.map((type) {
                      final isSelected = trackingState.activityType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => trackingNotifier.setActivityType(type),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 10)]
                                  : null,
                            ),
                            child: Column(
                              children: [
                                FaIcon(
                                  type.icon,
                                  color: isSelected ? Colors.black : AppColors.textSecondary,
                                  size: 18,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  type.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 24),

                  // Target Selector
                  Text(
                    isIndo ? "TARGET AKTIVITAS" : "ACTIVITY TARGET",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ["Bebas", "1 km", "3 km", "5 km", "10 km"].map((target) {
                        final isSelected = _selectedTarget == target;
                        final label = isIndo ? target : (_targetMapEn[target] ?? target);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTarget = target;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 24),

                  // Audio & AutoPause Options
                  Text(
                    isIndo ? "PENGATURAN CEPAT" : "QUICK SETTINGS",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.volume_up, color: AppColors.primary),
                          title: Text(
                            isIndo ? "Panduan Suara" : "Voice Audio Cues",
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Switch.adaptive(
                            value: _audioCues,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                _audioCues = val;
                              });
                            },
                          ),
                        ),
                        Divider(color: Colors.white.withOpacity(0.05), height: 1),
                        ListTile(
                          leading: const Icon(Icons.pause_circle_outline, color: AppColors.secondary),
                          title: Text(
                            isIndo ? "Jeda Otomatis" : "Auto-Pause",
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Switch.adaptive(
                            value: _autoPause,
                            activeColor: AppColors.secondary,
                            onChanged: (val) {
                              setState(() {
                                _autoPause = val;
                              });
                            },
                          ),
                        ),
                        Divider(color: Colors.white.withOpacity(0.05), height: 1),
                        ListTile(
                          leading: const Icon(Icons.favorite, color: AppColors.accent),
                          title: Text(
                            isIndo ? "Ukur Detak Jantung" : "Measure Heart Rate",
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Switch.adaptive(
                            value: _measureHeartRate,
                            activeColor: AppColors.accent,
                            onChanged: (val) {
                              setState(() {
                                _measureHeartRate = val;
                              });
                              if (val) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const HeartRatePage()),
                                ).then((_) {
                                  setState(() {
                                    _measureHeartRate = false;
                                  });
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 32),

                  // Giant Pulsing Record Button
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Open full map tracker screen
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
                          // Outer glow circle 1 (Pulsing)
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.2, 1.2),
                                duration: 1.5.seconds,
                                curve: Curves.easeInOut,
                              ),
                          // Outer glow circle 2 (Pulsing faster)
                          Container(
                            width: 115,
                            height: 115,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.15),
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.15, 1.15),
                                duration: 1.2.seconds,
                                curve: Curves.easeInOut,
                              ),
                          // Core Button
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.black,
                                    size: 36,
                                  ),
                                  Text(
                                    isIndo ? "MULAI" : "START",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 900.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutBack,
                        duration: 600.ms,
                      ),
                  const SizedBox(height: 100), // Padding to avoid overlap with navigation bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
