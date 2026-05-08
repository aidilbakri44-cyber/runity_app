import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../tracking/presentation/pages/tracking_page.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../tracking/presentation/providers/history_provider.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/localization/app_translations.dart';
import 'history_page.dart';
import 'package:intl/intl.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final history = ref.watch(trackingHistoryProvider);
    final settings = ref.watch(settingsProvider);
    final lang = settings.language;

    String t(String key) => AppTranslations.translate(lang, key);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              const SizedBox(height: 20),
              _buildHeader(context, profile, t),
              const SizedBox(height: 24),
              _buildSummaryCard(profile, history, t),
              const SizedBox(height: 24),
              _buildSportSelector(t),
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
              ),
              const SizedBox(height: 8),
              _buildRecentActivityList(history, t),
              const SizedBox(height: 24),
              _buildStartButton(context, t),
              const SizedBox(height: 24),
            ],
          ),
        ),
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
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: profile.avatarUrl.startsWith('http')
                      ? NetworkImage(profile.avatarUrl)
                      : FileImage(File(profile.avatarUrl)) as ImageProvider,
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

  Widget _buildRecentActivityList(List<Activity> history, Function(String) t) {
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
                MaterialPageRoute(builder: (context) => const TrackingPage()),
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
