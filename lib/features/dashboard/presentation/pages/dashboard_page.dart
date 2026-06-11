import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../tracking/presentation/providers/history_provider.dart';
import '../../../tracking/presentation/pages/tracking_page.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import 'activity_detail_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final history = ref.watch(trackingHistoryProvider);

    // Image Specific Colors
    const bgColor = Color(0xFF161618);
    const cardColor = Color(0xFF1C1C1E);
    const cyan = Color(0xFF00E5FF);
    const lime = Color(0xFFC4FF00);
    const pink = Color(0xFFFF80AB);
    const textSec = Color(0xFF888888);

    // Calculate Insights
    double weeklyDistance = history.fold(0, (sum, run) => sum + run.distance);
    int totalCalories = (weeklyDistance * 65).toInt(); // Approx
    int totalActiveMin = history.fold(0, (sum, run) => sum + run.duration.inMinutes);

    // Calculate progress bars (cap at 1.0)
    double distanceProgress = (weeklyDistance / 50.0).clamp(0.0, 1.0);
    double caloriesProgress = (totalCalories / 3000.0).clamp(0.0, 1.0);
    double activeMinProgress = (totalActiveMin / 300.0).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: cyan.withValues(alpha: 0.3), width: 2),
                          image: const DecorationImage(
                            image: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "WELCOME BACK",
                            style: GoogleFonts.inter(color: textSec, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                          Text(
                            profile.name.toUpperCase(),
                            style: GoogleFonts.inter(color: cyan, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    "RUNITY",
                    style: GoogleFonts.inter(color: cyan, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                    child: const Icon(Icons.settings_outlined, color: textSec),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // TOP SPRINT CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(
                    top: BorderSide(color: cyan, width: 3),
                  ),
                  boxShadow: [
                    BoxShadow(color: cyan.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: cyan, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "SYSTEM READY",
                          style: GoogleFonts.inter(color: cyan, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Ready for your night\nsprint?",
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "The optimal temperature is 18°C.\nPerfect for a personal best.",
                      style: GoogleFonts.inter(color: textSec, fontSize: 12, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(trackingProvider.notifier).startTracking();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const TrackingPage()),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_outlined, color: Colors.black, size: 20),
                        label: Text(
                          "START NEW RUN",
                          style: GoogleFonts.inter(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cyan,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // WEEKLY INSIGHTS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Weekly Insights", style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("WEEK 42", style: GoogleFonts.inter(color: textSec, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildInsightCard("DISTANCE", weeklyDistance.toStringAsFixed(1), "KM", cyan, distanceProgress),
              const SizedBox(height: 12),
              _buildInsightCard("CALORIES", NumberFormat("#,##0").format(totalCalories), "KCAL", lime, caloriesProgress),
              const SizedBox(height: 12),
              _buildInsightCard("ACTIVE MIN", totalActiveMin.toString(), "MIN", pink, activeMinProgress),

              const SizedBox(height: 32),

              // LAST RUN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Last Run", style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("VIEW ALL >", style: GoogleFonts.inter(color: cyan, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 16),
              _buildLastRunCard(context, history.isNotEmpty ? history.first : null, cyan, cardColor, textSec),

              const SizedBox(height: 24),

              // MILESTONES & RECORDS GRID
              Row(
                children: [
                  Expanded(child: _buildGridCard(Icons.workspace_premium_outlined, cyan, "MILESTONE", "100 KM\nCLUB", cardColor, textSec)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildGridCard(Icons.speed, lime, "RECORD", "FASTEST 5K", cardColor, textSec)),
                ],
              ),

              const SizedBox(height: 24),

              // STREAK
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("CURRENT STREAK", style: GoogleFonts.inter(color: textSec, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                        const SizedBox(height: 4),
                        Text("${profile.streakDays} DAYS", style: GoogleFonts.inter(color: cyan, fontSize: 20, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    Icon(Icons.local_fire_department_outlined, color: cyan.withValues(alpha: 0.3), size: 40),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(String label, String value, String unit, Color barColor, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: barColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: const Color(0xFF888888), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(unit, style: GoogleFonts.inter(color: barColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(2)),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 4,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(2)),
                  );
                }
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLastRunCard(BuildContext context, RunActivity? activity, Color cyan, Color cardColor, Color textSec) {
    final String dateStr = activity != null ? DateFormat('MMM d, yyyy').format(activity.date) : "Oct 24, 2023";
    final String distStr = activity != null ? "${activity.distance.toStringAsFixed(2)} KM" : "8.42 KM";
    final String paceStr = activity != null ? activity.pace : "4'52\" /KM";
    final String timeStr = activity != null 
        ? "${activity.duration.inMinutes}:${(activity.duration.inSeconds % 60).toString().padLeft(2, '0')}" 
        : "41:04";

    return GestureDetector(
      onTap: () {
        if (activity != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityDetailPage(activity: activity)));
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mock Map Area (using a gradient to simulate the map in the image for UI exactness)
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF222226),
              ),
              child: Stack(
                children: [
                  // Draw a glowing fake route
                  Center(
                    child: CustomPaint(
                      size: const Size(double.infinity, 140),
                      painter: _FakeRoutePainter(),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    child: Text("BERLIN MIDTOWN", style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatCol("DATE", dateStr, Colors.white, textSec),
                        const SizedBox(height: 16),
                        _buildStatCol("AVG PACE", paceStr, Colors.white, textSec),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatCol("DISTANCE", distStr, cyan, textSec),
                        const SizedBox(height: 16),
                        _buildStatCol("TIME", timeStr, Colors.white, textSec),
                      ],
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

  Widget _buildStatCol(String label, String value, Color valColor, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: labelColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(color: valColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGridCard(IconData icon, Color iconColor, String title, String value, Color cardColor, Color textSec) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.inter(color: textSec, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.2),
          ),
        ],
      ),
    );
  }
}

// Simple painter to simulate the route in the image
class _FakeRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    path.moveTo(size.width * 0.8, 0);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.3, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.7, size.width * 0.5, size.height);

    canvas.drawPath(path, paint);

    final solidPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    canvas.drawPath(path, solidPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
