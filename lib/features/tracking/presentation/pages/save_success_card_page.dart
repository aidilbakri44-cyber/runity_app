import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

import '../../../../core/constants/app_colors.dart';
import '../providers/history_provider.dart';

class SaveSuccessCardPage extends StatelessWidget {
  final Activity activity;

  const SaveSuccessCardPage({super.key, required this.activity});

  String _formatDistanceComma(double distance) {
    return distance.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _formatPaceColon(String pace) {
    // pace comes in as "5'22\"" format, convert to "5:22"
    String clean = pace.replaceAll("'", ':').replaceAll('"', '');
    if (clean == "-:--" || clean.isEmpty) return "-:--";
    return clean;
  }

  String _formatDurationShort(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return "${minutes}m ${seconds}d";
  }

  @override
  Widget build(BuildContext context) {
    final distStr = _formatDistanceComma(activity.distance);
    final paceStr = _formatPaceColon(activity.pace);
    final durationStr = _formatDurationShort(activity.duration);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Pop all the way back to dashboard
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white54, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Main card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),

                    // Route drawing area
                    if (activity.route.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 280,
                        child: CustomPaint(
                          painter: RoutePainter(
                            route: activity.route,
                            routeColor: AppColors.primary, // Cyber Green
                            strokeWidth: 4.5,
                          ),
                        ),
                      ).animate().fadeIn(duration: 800.ms).scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutBack,
                        duration: 600.ms,
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 280,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined, color: Colors.white.withOpacity(0.1), size: 80),
                              const SizedBox(height: 16),
                              Text(
                                "Tidak ada rute",
                                style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 800.ms),

                    const Spacer(flex: 1),

                    // RUNITY Logo
                    const Text(
                      'RUNITY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                    const SizedBox(height: 32),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn('Jarak', '$distStr km'),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        _buildStatColumn('Pace', '$paceStr /km'),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        _buildStatColumn('Waktu', durationStr),
                      ],
                    ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

                    const SizedBox(height: 32),

                    // Running shoe icon
                    Icon(
                      Icons.directions_run,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 28,
                    ).animate().fadeIn(delay: 800.ms, duration: 500.ms),

                    const Spacer(flex: 2),



                    // Back to dashboard button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: Text(
                          'Kembali ke Dashboard',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 1100.ms),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

/// Custom painter that draws the running route as a neon green line
/// on a black background, normalized to fit the canvas.
class RoutePainter extends CustomPainter {
  final List<LatLng> route;
  final Color routeColor;
  final double strokeWidth;

  RoutePainter({
    required this.route,
    required this.routeColor,
    this.strokeWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (route.isEmpty) return;

    // Find bounding box of the route
    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;

    for (final point in route) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;

    // Prevent division by zero for single-point or straight-line routes
    final effectiveLatRange = latRange == 0 ? 0.001 : latRange;
    final effectiveLngRange = lngRange == 0 ? 0.001 : lngRange;

    // Add padding (15% on each side)
    final padding = 0.15;
    final drawWidth = size.width * (1 - 2 * padding);
    final drawHeight = size.height * (1 - 2 * padding);
    final offsetX = size.width * padding;
    final offsetY = size.height * padding;

    // Scale to fit while maintaining aspect ratio
    final scaleX = drawWidth / effectiveLngRange;
    final scaleY = drawHeight / effectiveLatRange;
    final scale = math.min(scaleX, scaleY);

    // Center the route in the available space
    final routeDrawWidth = effectiveLngRange * scale;
    final routeDrawHeight = effectiveLatRange * scale;
    final centerOffsetX = offsetX + (drawWidth - routeDrawWidth) / 2;
    final centerOffsetY = offsetY + (drawHeight - routeDrawHeight) / 2;

    // Convert lat/lng to canvas coordinates
    List<Offset> points = route.map((point) {
      final x = centerOffsetX + (point.longitude - minLng) * scale;
      // Invert Y because latitude increases upward but canvas Y increases downward
      final y = centerOffsetY + (maxLat - point.latitude) * scale;
      return Offset(x, y);
    }).toList();

    if (points.length < 2) return;

    // Draw glow effect (outer soft line)
    final glowPaint = Paint()
      ..color = routeColor.withValues(alpha: 0.3)
      ..strokeWidth = strokeWidth * 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = ui.Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, glowPaint);

    // Draw main route line
    final mainPaint = Paint()
      ..color = routeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, mainPaint);

    // Draw start marker (filled circle)
    final startPaint = Paint()
      ..color = routeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(points.first, strokeWidth * 2.2, startPaint);

    // Inner dot for start
    final startInnerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(points.first, strokeWidth * 1.0, startInnerPaint);

    // Draw end marker (filled square)
    final endRect = Rect.fromCenter(
      center: points.last,
      width: strokeWidth * 4,
      height: strokeWidth * 4,
    );
    final endPaint = Paint()
      ..color = routeColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(endRect, const Radius.circular(2)),
      endPaint,
    );

    // Inner square for end
    final endInnerRect = Rect.fromCenter(
      center: points.last,
      width: strokeWidth * 2,
      height: strokeWidth * 2,
    );
    final endInnerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(endInnerRect, const Radius.circular(1)),
      endInnerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RoutePainter oldDelegate) {
    return oldDelegate.route != route || oldDelegate.routeColor != routeColor;
  }
}
