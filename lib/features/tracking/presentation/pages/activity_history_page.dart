import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/history_provider.dart';
import '../../../dashboard/presentation/pages/activity_detail_page.dart';

class ActivityHistoryPage extends ConsumerStatefulWidget {
  const ActivityHistoryPage({super.key});

  @override
  ConsumerState<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends ConsumerState<ActivityHistoryPage> {
  String _selectedTab = "Week";

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(trackingHistoryProvider);

    const bgColor = Color(0xFF161618);
    const cardColor = Color(0xFF1C1C1E);
    const cyan = Color(0xFF00E5FF);
    const textSec = Color(0xFF888888);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cyan.withValues(alpha: 0.3), width: 1.5),
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    "RUNITY",
                    style: GoogleFonts.inter(color: cyan, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                  const Icon(Icons.notifications_none, color: cyan), // Matched cyan bell
                ],
              ),
            ),
            
            // TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Activity History",
                style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // TABS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildTab("Week", _selectedTab == "Week", cyan),
                  const SizedBox(width: 8),
                  _buildTab("Month", _selectedTab == "Month", cyan),
                  const SizedBox(width: 8),
                  _buildTab("Year", _selectedTab == "Year", cyan),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // LIST
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Text(
                        "No activities yet.",
                        style: GoogleFonts.inter(color: textSec, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                      itemCount: history.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final activity = history[index];
                        // Cycle neon colors for maps
                        final colors = [cyan, const Color(0xFFC4FF00), const Color(0xFFFF80AB)];
                        final routeColor = colors[index % colors.length];
                        final showGpsTag = index == 0; // Show tag on first item like in image

                        return _buildHistoryCard(context, activity, cardColor, textSec, routeColor, showGpsTag);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected, Color cyan) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cyan : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? cyan : Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Activity activity, Color cardColor, Color textSec, Color routeColor, bool showGpsTag) {
    final cyan = const Color(0xFF00E5FF);
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(activity.date).toUpperCase();
    final timeStr = "${activity.duration.inMinutes}:${(activity.duration.inSeconds % 60).toString().padLeft(2, '0')}";
    final title = activity.title ?? (activity.date.hour < 12 ? "Morning Urban Sprint" : "Neon Night Ride");

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityDetailPage(activity: activity)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: GoogleFonts.inter(color: cyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white54, size: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat("DISTANCE", "${activity.distance.toStringAsFixed(1)} KM", textSec),
                      _buildStat("PACE", "${activity.pace} /KM", textSec),
                      _buildStat("TIME", timeStr, textSec),
                    ],
                  ),
                ],
              ),
            ),
            // Map graphic area
            Container(
              height: 120,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF161618),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Center(
                    child: CustomPaint(
                      size: const Size(double.infinity, 120),
                      painter: _NeonRoutePainter(routeColor),
                    ),
                  ),
                  if (showGpsTag)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC4FF00).withValues(alpha: 0.1),
                          border: Border.all(color: const Color(0xFFC4FF00)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "GPS:\nLOCKED",
                          style: GoogleFonts.inter(color: const Color(0xFFC4FF00), fontSize: 8, fontWeight: FontWeight.w900, height: 1.1),
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

  Widget _buildStat(String label, String value, Color textSec) {
    // Split value and unit if possible
    String val = value;
    String unit = "";
    if (value.contains(" ")) {
      final parts = value.split(" ");
      val = parts[0];
      unit = parts.sublist(1).join(" ");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: textSec, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(val, style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(unit, style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
      ],
    );
  }
}

class _NeonRoutePainter extends CustomPainter {
  final Color routeColor;

  _NeonRoutePainter(this.routeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = routeColor.withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final solidPaint = Paint()
      ..color = routeColor.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Create a random-looking squiggly route based on color hash to make them slightly different
    final isCyan = routeColor == const Color(0xFF00E5FF);
    final isLime = routeColor == const Color(0xFFC4FF00);
    
    if (isCyan) {
      path.moveTo(size.width * 0.3, 0);
      path.quadraticBezierTo(size.width * 0.4, size.height * 0.4, size.width * 0.5, size.height * 0.3);
      path.quadraticBezierTo(size.width * 0.7, size.height * 0.2, size.width * 0.6, size.height * 0.8);
      path.quadraticBezierTo(size.width * 0.5, size.height * 1.2, size.width * 0.8, size.height);
    } else if (isLime) {
      path.moveTo(0, size.height * 0.5);
      path.quadraticBezierTo(size.width * 0.3, size.height * 0.8, size.width * 0.5, size.height * 0.4);
      path.quadraticBezierTo(size.width * 0.7, 0, size.width * 0.8, size.height * 0.6);
      path.lineTo(size.width, size.height * 0.7);
    } else {
      path.moveTo(size.width * 0.8, 0);
      path.quadraticBezierTo(size.width * 0.6, size.height * 0.5, size.width * 0.5, size.height * 0.3);
      path.quadraticBezierTo(size.width * 0.2, 0, size.width * 0.3, size.height * 0.8);
      path.lineTo(size.width * 0.4, size.height);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, solidPaint);
  }

  @override
  bool shouldRepaint(covariant _NeonRoutePainter oldDelegate) {
    return oldDelegate.routeColor != routeColor;
  }
}
