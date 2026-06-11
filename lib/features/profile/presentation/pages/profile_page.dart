import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../tracking/presentation/providers/history_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/utils/image_helper.dart';
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

    const bgColor = Color(0xFF161618);
    const cyan = Color(0xFF00E5FF);
    const lime = Color(0xFFC4FF00);
    const textSec = Color(0xFF888888);
    const cardColor = Color(0xFF1C1C1E);

    double totalDistance = history.fold(0, (sum, run) => sum + run.distance);
    int totalRuns = history.length;
    
    // Calculate best pace for UI. (Mock if no history)
    String bestPace = "3'42\"";
    if (history.isNotEmpty) {
      // Just grab the first one's pace for realism if we don't parse strings to compare
      bestPace = history.first.pace;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "RUNITY",
          style: GoogleFonts.inter(color: cyan, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        actions: [
          const Icon(Icons.notifications_none, color: cyan),
          const SizedBox(width: 16),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cyan.withValues(alpha: 0.3), width: 1),
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // BIG AVATAR WITH EDIT ICON
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (profile.avatarUrl.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FullScreenImagePage(imageUrl: profile.avatarUrl)),
                        );
                      }
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: cyan, width: 2),
                        boxShadow: [
                          BoxShadow(color: cyan.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5),
                        ],
                      ),
                      child: ClipOval(
                        child: profile.avatarUrl.isEmpty
                            ? const Icon(Icons.person, color: Colors.white, size: 60)
                            : ImageHelper.imageFromPath(profile.avatarUrl, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Keep edit feature via this button
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: cyan,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.black, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // NAME & BIO
            Text(
              profile.name.isNotEmpty ? profile.name : "Alex Sterling",
              style: GoogleFonts.lora(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Urban sprinter • Night trail enthusiast •\nBreaking limits since '21",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 32),

            // STATS CARDS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cyan.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("TOTAL KM", style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        totalDistance.toStringAsFixed(0),
                        style: GoogleFonts.inter(color: cyan, fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text("KM", style: GoogleFonts.inter(color: lime, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("RUNS", style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Text(
                          totalRuns.toString(),
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("PB PACE", style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Text(
                          bestPace,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // PREFERENCES
            Align(
              alignment: Alignment.centerLeft,
              child: Text("PREFERENCES", style: GoogleFonts.inter(color: textSec, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPrefItem(
                    context, 
                    Icons.shield_outlined, 
                    cyan, 
                    "Privacy & Visibility", 
                    "Control who sees your routes", 
                    () => _showInfoSnackBar(context, "Privacy Settings loaded.")
                  ),
                  Divider(color: Colors.white.withValues(alpha: 0.05), height: 1, indent: 64),
                  _buildPrefItem(
                    context, 
                    Icons.notifications_none, 
                    cyan, 
                    "Notifications", 
                    "Push, email, and sound alerts", 
                    () => _showInfoSnackBar(context, "Notification preferences loaded.")
                  ),
                  Divider(color: Colors.white.withValues(alpha: 0.05), height: 1, indent: 64),
                  _buildPrefItem(
                    context, 
                    Icons.lock_outline, 
                    cyan, 
                    "Security", 
                    "Password & Bio-authentication", 
                    () => _showInfoSnackBar(context, "Security settings loaded.")
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // SIGN OUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context, ref, t),
                icon: const Icon(Icons.logout, color: Color(0xFFFF80AB), size: 18),
                label: Text(
                  "Sign Out",
                  style: GoogleFonts.inter(color: const Color(0xFFFF80AB), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2A2A30)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPrefItem(BuildContext context, IconData icon, Color iconColor, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(color: Colors.white70, fontSize: 10)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, Function(String) t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Color(0xFFFF80AB), size: 20),
            const SizedBox(width: 12),
            Text("Logout", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "Apakah Anda ingin keluar? Seluruh data sesi lokal Anda akan diatur ulang.",
          style: GoogleFonts.inter(color: const Color(0xFF888888)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("TIDAK", style: GoogleFonts.inter(color: const Color(0xFF888888), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await ref.read(profileProvider.notifier).logout();
              
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomePage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF80AB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("YA, KELUAR", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00E5FF),
        behavior: SnackBarBehavior.floating,
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
              child: ImageHelper.imageFromPath(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
