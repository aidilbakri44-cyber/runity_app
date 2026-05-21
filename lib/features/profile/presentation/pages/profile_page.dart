import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../tracking/presentation/providers/history_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_page.dart';
import 'welcome_page.dart';

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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, profile, ref),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainStats(history, t)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 32),
                  Text(
                    t('account').toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: 16),
                  _buildSettingsItem(context, t('edit_profile'), FontAwesomeIcons.userPen, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
                  }).animate().fadeIn(delay: 400.ms),
                  _buildSettingsItem(context, t('privacy_settings'), FontAwesomeIcons.shieldHalved, () {
                    _showInfoSnackBar(context, "Privacy Settings loaded.");
                  }).animate().fadeIn(delay: 500.ms),
                  _buildSettingsItem(context, t('notifications'), FontAwesomeIcons.bell, () {
                    _showInfoSnackBar(context, "Notification preferences loaded.");
                  }).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => _showLogoutDialog(context, ref, t),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      t('logout'), 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)
                    ),
                  ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, Function(String) t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.arrowRightFromBracket, color: AppColors.accent, size: 20),
            SizedBox(width: 12),
            Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Apakah Anda ingin keluar? Seluruh data sesi lokal Anda akan diatur ulang.",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("TIDAK", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await ref.read(profileProvider.notifier).logout();
              
              if (context.mounted) {
                // Navigate back to WelcomePage and clear the stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomePage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("YA, KELUAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, profile, WidgetRef ref) {
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
              "https://images.unsplash.com/photo-1552674605-db6ffd4facb5?q=80&w=1200",
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
              child: Stack(
                children: [
                  GestureDetector(
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
                        child: ClipOval(
                          child: Container(
                            width: 120,
                            height: 120,
                            color: AppColors.surface,
                            child: profile.avatarUrl.isEmpty
                                ? const Icon(Icons.person, color: Colors.white, size: 40)
                                : (kIsWeb 
                                    ? Image.network(profile.avatarUrl, fit: BoxFit.cover)
                                    : Image.file(File(profile.avatarUrl), fit: BoxFit.cover)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 48,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _pickImageFromGallery(context, ref),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.edit, color: Colors.black, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery(BuildContext context, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );

    if (image != null) {
      ref.read(profileProvider.notifier).updateAvatar(image.path);
      final settings = ref.read(settingsProvider);
      final message = AppTranslations.translate(settings.language, 'profile_updated');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildMainStats(List<Activity> history, Function(String) t) {
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
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
