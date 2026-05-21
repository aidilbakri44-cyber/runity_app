import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import 'dashboard_page.dart';
import '../../../tracking/presentation/pages/peta_page.dart';
import '../../../tracking/presentation/pages/rekam_page.dart';
import 'grup_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardPage(),
      const PetaPage(),
      const RekamPage(),
      const GrupPage(),
      const ProfilePage(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final lang = settings.language;
    final isIndo = lang == 'Bahasa Indonesia';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Keeping state of all pages alive with IndexedStack
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          // Floating Glassmorphic Bottom Navigation Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _buildFloatingBottomNavBar(context, isIndo),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomNavBar(BuildContext context, bool isIndo) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: FontAwesomeIcons.house,
                label: isIndo ? "Home" : "Home",
                hasBadge: true,
                badgeValue: "7",
              ),
              _buildNavItem(
                index: 1,
                icon: FontAwesomeIcons.map,
                label: isIndo ? "Peta" : "Map",
              ),
              _buildCenterNavItem(
                index: 2,
                label: isIndo ? "Rekam" : "Record",
              ),
              _buildNavItem(
                index: 3,
                icon: FontAwesomeIcons.peopleGroup,
                label: isIndo ? "Grup" : "Groups",
              ),
              _buildNavItem(
                index: 4,
                icon: FontAwesomeIcons.chartSimple,
                label: isIndo ? "Anda" : "You",
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack);
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    bool hasBadge = false,
    String badgeValue = "",
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = AppColors.primary;
    final inactiveColor = Colors.white.withOpacity(0.4);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Icon
                AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  scale: isSelected ? 1.2 : 1.0,
                  child: FaIcon(
                    icon,
                    color: isSelected ? activeColor : inactiveColor,
                    size: 20,
                  ),
                ),
                // Notification Badge
                if (hasBadge)
                  Positioned(
                    right: -10,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          badgeValue,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.15, 1.15), duration: 1.seconds),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // Text Label
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            // Dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(0.8),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem({
    required int index,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = AppColors.primary;
    final inactiveColor = Colors.white.withOpacity(0.4);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom Double-Circle Record Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : Colors.white.withOpacity(0.5),
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? activeColor : Colors.white.withOpacity(0.8),
                  ),
                ).animate(target: isSelected ? 1 : 0, onPlay: (c) => c.repeat(reverse: true))
                 .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.15, 1.15), duration: 1.seconds),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            // Dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(0.8),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
