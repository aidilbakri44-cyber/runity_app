import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../providers/profile_provider.dart';
import '../../../tracking/presentation/providers/history_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/localization/app_translations.dart';
import 'edit_profile_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final history = ref.watch(trackingHistoryProvider);
    final settings = ref.watch(settingsProvider);
    final lang = settings.language;

    String t(String key) => AppTranslations.translate(lang, key);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, profile),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildMainStats(history, t),
                    const SizedBox(height: 32),
                    _buildAchievements(history, t),
                    const SizedBox(height: 32),
                    _buildSettingsItem(context, t('edit_profile'), FontAwesomeIcons.userPen, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
                    }),
                    _buildSettingsItem(context, t('privacy_settings'), FontAwesomeIcons.shieldHalved, () {
                      _showInfoSnackBar(context, "Privacy Settings loaded.");
                    }),
                    _buildSettingsItem(context, t('notifications'), FontAwesomeIcons.bell, () {
                      _showInfoSnackBar(context, "Notification preferences loaded.");
                    }),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(t('logout'), style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, profile) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              "https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?q=80&w=1000",
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.background.withOpacity(0.8), AppColors.background],
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImagePage(imageUrl: profile.avatarUrl),
                    ),
                  );
                },
                child: Hero(
                  tag: "profile_avatar",
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 4),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 30),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: profile.avatarUrl.startsWith('http')
                          ? NetworkImage(profile.avatarUrl)
                          : FileImage(File(profile.avatarUrl)) as ImageProvider,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStats(List<RunActivity> history, Function(String) t) {
    double totalDistance = history.fold(0, (sum, run) => sum + run.distance);
    int totalRuns = history.length;
    
    return Row(
      children: [
        Expanded(child: _buildStatCard(t('total_distance'), totalDistance.toStringAsFixed(1), FontAwesomeIcons.road)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(t('runs'), totalRuns.toString(), FontAwesomeIcons.personRunning)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            FaIcon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(List<RunActivity> history, Function(String) t) {
    double totalDistance = history.fold(0, (sum, run) => sum + run.distance);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('achievements'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildBadge(FontAwesomeIcons.trophy, "Early Bird", history.isNotEmpty),
              _buildBadge(FontAwesomeIcons.medal, "10K Club", totalDistance >= 10),
              _buildBadge(FontAwesomeIcons.award, "Streak King", history.length >= 3),
              _buildBadge(FontAwesomeIcons.rankingStar, "Elite", totalDistance >= 50),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label, bool isUnlocked) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? AppColors.surface : AppColors.surface.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: isUnlocked ? AppColors.primary : Colors.white.withOpacity(0.05)),
            ),
            child: FaIcon(
              icon, 
              color: isUnlocked ? Colors.amber : Colors.grey.withOpacity(0.3), 
              size: 24
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label, 
            style: TextStyle(fontSize: 10, color: isUnlocked ? Colors.white : Colors.grey), 
            textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          child: ListTile(
            leading: FaIcon(icon, color: Colors.white70, size: 18),
            title: Text(title, style: const TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, size: 18),
          ),
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final isLocal = !imageUrl.startsWith('http');
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: "profile_avatar",
            child: InteractiveViewer(
              child: isLocal
                  ? Image.file(File(imageUrl), fit: BoxFit.contain)
                  : Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
