import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard_page.dart';
import '../../../tracking/presentation/pages/activity_history_page.dart';
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
      const ActivityHistoryPage(),
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
    final isIndo = settings.language == 'Bahasa Indonesia';

    return Scaffold(
      backgroundColor: const Color(0xFF161618),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E22), // Flat dark color from the image bottom nav
          border: Border(
            top: BorderSide(
              color: Color(0xFF2A2A30),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_outlined, isIndo ? "Dash" : "Dash"),
                _buildNavItem(1, Icons.history, isIndo ? "Riwayat" : "History"),
                _buildNavItem(2, Icons.person_outline, isIndo ? "Profil" : "Profile"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final activeColor = const Color(0xFF00E5FF); // Cyan from the image
    final inactiveColor = Colors.white54;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? activeColor : inactiveColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected ? activeColor : inactiveColor,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
