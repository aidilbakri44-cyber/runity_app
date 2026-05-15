import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../tracking/presentation/providers/history_provider.dart';

class ActivityDetailPage extends StatefulWidget {
  final Activity activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  bool _isPanelVisible = true;

  void _shareActivity() {
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(widget.activity.date);
    final text = "Saya baru saja menyelesaikan ${widget.activity.type.name} sejauh ${widget.activity.distance.toStringAsFixed(2)} km pada $dateStr menggunakan Runity! 🏃‍♂️💨";
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background OpenStreetMap
          _buildMap(),
          
          // Header overlay
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPanelVisible = !_isPanelVisible;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isPanelVisible ? Colors.black.withOpacity(0.7) : AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white10),
                      boxShadow: _isPanelVisible ? [] : [
                        BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 10),
                      ],
                    ),
                    child: Icon(
                      _isPanelVisible ? Icons.map : Icons.visibility,
                      color: _isPanelVisible ? Colors.white : Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Activity Stats Panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutQuart,
            bottom: _isPanelVisible ? 0 : -400,
            left: 0,
            right: 0,
            child: _buildStatsPanel(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: widget.activity.route.isNotEmpty 
            ? widget.activity.route[widget.activity.route.length ~/ 2] 
            : const LatLng(-6.200000, 106.816666),
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.runity.app',
        ),
        if (widget.activity.route.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.activity.route,
                color: AppColors.primary,
                strokeWidth: 5,
              ),
            ],
          ),
        MarkerLayer(
          markers: widget.activity.route.isEmpty ? [] : [
            // Start Marker
            Marker(
              point: widget.activity.route.first,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on, color: Colors.green, size: 40),
            ),
            // End Marker
            Marker(
              point: widget.activity.route.last,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d, yyyy').format(widget.activity.date),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(widget.activity.type.icon, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        widget.activity.type.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: _shareActivity,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: const FaIcon(FontAwesomeIcons.shareNodes, color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("DISTANCE", widget.activity.distance.toStringAsFixed(2), "km"),
              _buildStatItem("DURATION", _formatDuration(widget.activity.duration), "min"),
              _buildStatItem("AVG PACE", widget.activity.pace, "/km"),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                unit,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    if (duration.inHours > 0) {
      return "${duration.inHours}:$twoDigitMinutes";
    }
    return duration.inMinutes.toString();
  }
}
