import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../tracking/presentation/pages/tracking_page.dart';

import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../tracking/presentation/providers/history_provider.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../tracking/domain/models/tracking_state.dart';
import 'history_page.dart';
import 'activity_detail_page.dart';


class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final history = ref.watch(trackingHistoryProvider);
    final settings = ref.watch(settingsProvider);
    final trackingState = ref.watch(trackingProvider);
    final lang = settings.language;

    String t(String key) => AppTranslations.translate(lang, key);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          // Advanced Multi-layered Background
          Container(
            decoration: const BoxDecoration(color: Color(0xFF000000)),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
              ),
            ).animate(onPlay: (c) => c.repeat()).blur(begin: const Offset(80, 80), end: const Offset(100, 100), duration: 4.seconds),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.1),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).blur(begin: const Offset(60, 60), end: const Offset(80, 80), duration: 5.seconds),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),
          
          // Decorative Background Lines
          Positioned(
            top: -50,
            left: -50,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 200,
                height: 400,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.03), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .moveY(begin: 0, end: 20, duration: 3.seconds, curve: Curves.easeInOut),
          
          Positioned(
            bottom: 100,
            right: -80,
            child: Transform.rotate(
              angle: -0.8,
              child: Container(
                width: 150,
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary.withOpacity(0.05), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .moveX(begin: 0, end: -20, duration: 4.seconds, curve: Curves.easeInOut),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                const SizedBox(height: 20),
                _buildHeader(context, profile, t)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: -0.1, end: 0),
                const SizedBox(height: 24),
                if (trackingState.status == TrackingStatus.running || trackingState.status == TrackingStatus.paused)
                  _buildActiveRunCard(context, trackingState, t)
                    .animate()
                    .fadeIn()
                    .slideY(begin: -0.2, end: 0),
                _buildSummaryCard(profile, history, t)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                const SizedBox(height: 24),
                _buildSportSelector(t)
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t('recent_activity'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const HistoryPage()),
                        );
                      },
                      child: Text(t('see_all'), style: const TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 8),
                _buildRecentActivityList(history, t)
                  .animate()
                  .fadeIn(delay: 800.ms)
                  .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 24),
                
                // Last Run Reference Card
                if (history.isNotEmpty)
                  _buildLastRunReference(context, history.first, t)
                    .animate()
                    .fadeIn(delay: 900.ms)
                    .slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 16),
                _buildStartButton(context, t)
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2.seconds, color: Colors.white24)
                  .animate()
                  .fadeIn(delay: 1000.ms)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: Curves.easeOutBack),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, profile, Function(String) t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipOval(
                  child: Container(
                    width: 48,
                    height: 48,
                    color: AppColors.surface,
                    child: profile.avatarUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.white, size: 20)
                        : (kIsWeb 
                                ? Image.network(profile.avatarUrl, fit: BoxFit.cover)
                                : Image.file(File(profile.avatarUrl), fit: BoxFit.cover)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${t('hello')}, ${profile.name.split(' ')[0]}!",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                Text(
                  t('ready_to_run'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
              },
              icon: const FaIcon(FontAwesomeIcons.clockRotateLeft, color: AppColors.textSecondary, size: 20),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              icon: const FaIcon(FontAwesomeIcons.gear, color: AppColors.textSecondary, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(profile, List<RunActivity> history, Function(String) t) {
    double totalDistance = history.fold(0, (sum, run) => sum + run.distance);
    int totalRuns = history.length;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(t('distance'), totalDistance.toStringAsFixed(1), "km", FontAwesomeIcons.route),
                _buildStatItem(t('runs'), totalRuns.toString(), "pts", FontAwesomeIcons.personRunning),
                _buildStatItem(t('streak'), profile.streakDays.toString(), "days", FontAwesomeIcons.fire),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.bolt, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  "Level ${profile.level}",
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text("${profile.xp} / ${profile.nextLevelXp} XP", style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: profile.xp / profile.nextLevelXp,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit, IconData icon) {
    return Column(
      children: [
        FaIcon(icon, color: AppColors.textSecondary.withOpacity(0.5), size: 16),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(unit, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
            ),
          ],
        ),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }

  Widget _buildSportSelector(Function(String) t) {
    return Consumer(
      builder: (context, ref, child) {
        final trackingState = ref.watch(trackingProvider);
        final notifier = ref.read(trackingProvider.notifier);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Activity",
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: SportType.values.map((type) {
                  final isSelected = trackingState.activityType == type;
                  return GestureDetector(
                    onTap: () => notifier.setActivityType(type),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: (isSelected == true) ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (isSelected == true) ? AppColors.primary : Colors.white.withOpacity(0.05)),
                        boxShadow: (isSelected == true) ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10)] : null,
                      ),
                      child: Row(
                        children: [
                          FaIcon(type.icon, color: (isSelected == true) ? Colors.black : AppColors.textSecondary, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            type.name,
                            style: TextStyle(
                              color: (isSelected == true) ? Colors.black : AppColors.textSecondary,
                              fontWeight: (isSelected == true) ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveRunCard(BuildContext context, TrackingState state, Function(String) t) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const TrackingPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.2), Colors.black.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ).animate(onPlay: (c) => c.repeat()).scale(duration: 1.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)).then().fadeOut(),
                    const SizedBox(width: 8),
                    const Text(
                      "LIVE TRACKING",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                    ),
                  ],
                ),
                Text(
                  state.status == TrackingStatus.paused ? "PAUSED" : "RECORDING",
                  style: TextStyle(color: state.status == TrackingStatus.paused ? Colors.amber : AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Mini Map
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: state.lastPosition ?? const LatLng(0, 0),
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
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
                              strokeWidth: 3,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLiveMetric("JARAK", state.formattedDistance),
                      const SizedBox(height: 12),
                      _buildLiveMetric("DURASI", state.formattedDuration),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildLastRunReference(BuildContext context, RunActivity activity, Function(String) t) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityDetailPage(activity: activity),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.clockRotateLeft, color: AppColors.primary, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    "REFERENSI LARI TERAKHIR",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              if (activity.route.isNotEmpty)
                const Icon(Icons.map_outlined, color: AppColors.primary, size: 14),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (activity.route.isNotEmpty)
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: activity.route.isNotEmpty ? activity.route.first : const LatLng(0, 0),
                      initialZoom: 14,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.runity.app',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: activity.route,
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d').format(activity.date),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity.type.name.toUpperCase(),
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMiniStat(activity.distance.toStringAsFixed(2), "km"),
                        const SizedBox(width: 16),
                        _buildMiniStat(activity.pace, "pace"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMiniStat(String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          unit,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList(List<RunActivity> history, Function(String) t) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.ghost, color: AppColors.textSecondary.withOpacity(0.3), size: 40),
            const SizedBox(height: 16),
            Text(t('no_activity'), style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: history.length > 5 ? 5 : history.length,
      itemBuilder: (context, index) {
        final activity = history[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(activity.type.icon, color: AppColors.primary, size: 16),
              ),
              title: Text(
                DateFormat('EEEE, MMM d').format(activity.date),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${activity.distance.toStringAsFixed(2)} km • ${activity.pace}"),
              trailing: const Icon(Icons.chevron_right, size: 18),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartButton(BuildContext context, Function(String) t) {
    return Consumer(
      builder: (context, ref, child) {
        final trackingState = ref.watch(trackingProvider);
        return Container(
          width: double.infinity,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
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
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(trackingState.activityType.icon, size: 24),
                const SizedBox(width: 12),
                Text(
                  "${t('start_run').split(' ')[0]} ${trackingState.activityType.name.toUpperCase()}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
