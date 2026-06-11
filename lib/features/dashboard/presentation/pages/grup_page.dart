import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/utils/image_helper.dart';

class GrupPage extends ConsumerStatefulWidget {
  const GrupPage({super.key});

  @override
  ConsumerState<GrupPage> createState() => _GrupPageState();
}

class _GrupPageState extends ConsumerState<GrupPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final lang = settings.language;
    final isIndo = lang == 'Bahasa Indonesia';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background decorative glow
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.08),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).blur(begin: const Offset(80, 80), end: const Offset(100, 100), duration: 6.seconds),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Text(
                    isIndo ? "Komunitas & Grup" : "Community & Groups",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),

                // Custom Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.white70,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: [
                        Tab(text: isIndo ? "Tantangan" : "Challenges"),
                        Tab(text: isIndo ? "Papan Peringkat" : "Leaderboard"),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 500.ms),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildChallengesTab(isIndo),
                      _buildLeaderboardTab(isIndo),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab(bool isIndo) {
    final challenges = [
      {
        "title": isIndo ? "Lari Mei 50K" : "May 50K Running",
        "description": isIndo ? "Selesaikan lari total 50 kilometer di bulan Mei." : "Complete a total of 50 km running in May.",
        "progress": 24.5,
        "target": 50.0,
        "unit": "km",
        "daysLeft": 10,
        "gradient": const [AppColors.primary, AppColors.secondary],
      },
      {
        "title": isIndo ? "Raja Tanjakan" : "Elevation King",
        "description": isIndo ? "Capai akumulasi kenaikan elevasi 300 meter." : "Reach 300 meters of cumulative elevation gain.",
        "progress": 120.0,
        "target": 300.0,
        "unit": "m",
        "daysLeft": 15,
        "gradient": const [Color(0xFFFF2D55), Color(0xFFFF9500)],
      },
      {
        "title": isIndo ? "Konsistensi Mingguan" : "Weekly Consistency",
        "description": isIndo ? "Mulai lari minimal 3 kali dalam seminggu." : "Run at least 3 times in a week.",
        "progress": 2.0,
        "target": 3.0,
        "unit": "x",
        "daysLeft": 3,
        "gradient": const [Color(0xFF00E5FF), Color(0xFF007AFF)],
      }
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        final title = challenge["title"] as String;
        final description = challenge["description"] as String;
        final progress = challenge["progress"] as double;
        final target = challenge["target"] as double;
        final unit = challenge["unit"] as String;
        final daysLeft = challenge["daysLeft"] as int;
        final gradientColors = challenge["gradient"] as List<Color>;
        final ratio = progress / target;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isIndo ? "$daysLeft hari tersisa" : "$daysLeft days left",
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${progress.toStringAsFixed(1)} / ${target.toStringAsFixed(0)} $unit",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${(ratio * 100).toStringAsFixed(0)}%",
                        style: TextStyle(color: gradientColors[0], fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress indicator
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 8,
                        width: MediaQuery.of(context).size.width * 0.7 * ratio,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: gradientColors[0].withOpacity(0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: (index * 150).ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildLeaderboardTab(bool isIndo) {
    final profile = ref.watch(profileProvider);

    // Mock weekly run distances
    final leaderboard = [
      {"rank": 1, "name": "Bill Leonardo", "distance": "42.5 km", "avatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150"},
      {"rank": 2, "name": "Aidil Bakri", "distance": "38.2 km", "avatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150"},
      {"rank": 3, "name": "Jessica Tan", "distance": "31.0 km", "avatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150"},
      {"rank": 4, "name": "Budi Santoso", "distance": "29.5 km", "avatar": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150"},
      {"rank": 5, "name": profile.name, "distance": "24.5 km", "isUser": true, "avatar": profile.avatarUrl},
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final runner = leaderboard[index];
        final rank = runner["rank"] as int;
        final name = runner["name"] as String;
        final distance = runner["distance"] as String;
        final isUser = runner["isUser"] == true;
        final avatar = runner["avatar"] as String;

        Color rankColor = Colors.white54;
        if (rank == 1) rankColor = const Color(0xFFFFD700); // Gold
        if (rank == 2) rankColor = const Color(0xFFC0C0C0); // Silver
        if (rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary.withOpacity(0.05) : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isUser ? AppColors.primary.withOpacity(0.4) : Colors.white.withOpacity(0.05),
                width: isUser ? 1.5 : 1,
              ),
            ),
            child: ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    alignment: Alignment.center,
                    child: Text(
                      "$rank",
                      style: TextStyle(
                        color: rankColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isUser ? AppColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: avatar.isEmpty
                          ? Container(color: Colors.white10, child: const Icon(Icons.person, color: Colors.white70, size: 18))
                          : ImageHelper.imageFromPath(avatar, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                  color: isUser ? AppColors.primary : Colors.white,
                ),
              ),
              subtitle: Text(
                isUser ? (isIndo ? "Peringkat Anda" : "Your Rank") : (isIndo ? "Pelari Runity" : "Runity Runner"),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              trailing: Text(
                distance,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: (index * 100).ms, duration: 400.ms).slideX(begin: -0.05, end: 0);
      },
    );
  }
}
