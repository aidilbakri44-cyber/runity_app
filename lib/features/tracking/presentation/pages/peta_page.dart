import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/localization/app_translations.dart';

class PetaPage extends ConsumerStatefulWidget {
  const PetaPage({super.key});

  @override
  ConsumerState<PetaPage> createState() => _PetaPageState();
}

class _PetaPageState extends ConsumerState<PetaPage> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(-6.200000, 106.816666);
  List<LatLng> _activeRoutePoints = [];
  String _selectedRouteName = "";
  double _zoomLevel = 15.0;

  // Mock popular trails in Jakarta
  final List<Map<String, dynamic>> _popularTrails = [
    {
      "name": "Sudirman Loop (CFD)",
      "distance": "5.2 km",
      "elevation": "12m",
      "difficulty": "Mudah",
      "center": const LatLng(-6.210000, 106.813000),
      "points": [
        const LatLng(-6.200000, 106.816666),
        const LatLng(-6.205000, 106.819000),
        const LatLng(-6.215000, 106.818000),
        const LatLng(-6.220000, 106.810000),
        const LatLng(-6.210000, 106.805000),
        const LatLng(-6.200000, 106.816666),
      ]
    },
    {
      "name": "GBK Outer Ring",
      "distance": "1.5 km",
      "elevation": "5m",
      "difficulty": "Mudah",
      "center": const LatLng(-6.218500, 106.804500),
      "points": [
        const LatLng(-6.218500, 106.801500),
        const LatLng(-6.215000, 106.804000),
        const LatLng(-6.216000, 106.808000),
        const LatLng(-6.221000, 106.806000),
        const LatLng(-6.218500, 106.801500),
      ]
    },
    {
      "name": "Taman Menteng Explorer",
      "distance": "3.0 km",
      "elevation": "8m",
      "difficulty": "Sedang",
      "center": const LatLng(-6.196000, 106.832000),
      "points": [
        const LatLng(-6.196000, 106.832000),
        const LatLng(-6.192000, 106.835000),
        const LatLng(-6.190000, 106.830000),
        const LatLng(-6.198000, 106.828000),
        const LatLng(-6.196000, 106.832000),
      ]
    }
  ];

  void _selectRoute(Map<String, dynamic> trail) {
    setState(() {
      _selectedRouteName = trail["name"];
      _activeRoutePoints = trail["points"] as List<LatLng>;
      _currentCenter = trail["center"] as LatLng;
      _zoomLevel = 14.5;
    });

    _mapController.move(_currentCenter, _zoomLevel);
  }

  void _clearRoute() {
    setState(() {
      _selectedRouteName = "";
      _activeRoutePoints = [];
      _currentCenter = const LatLng(-6.200000, 106.816666);
      _zoomLevel = 15.0;
    });
    _mapController.move(_currentCenter, _zoomLevel);
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
          // OpenStreetMap View
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: _zoomLevel,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.runity.app',
              ),
              if (_activeRoutePoints.isNotEmpty) ...[
                PolylineLayer(
                  polylines: [
                    // Outer glow
                    Polyline(
                      points: _activeRoutePoints,
                      color: AppColors.primary.withOpacity(0.4),
                      strokeWidth: 9,
                    ),
                    // Inner line
                    Polyline(
                      points: _activeRoutePoints,
                      color: AppColors.primary,
                      strokeWidth: 4.5,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Start Marker
                    Marker(
                      point: _activeRoutePoints.first,
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.play_arrow, color: Colors.black, size: 16),
                        ),
                      ),
                    ),
                    // End Marker
                    Marker(
                      point: _activeRoutePoints.last,
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.flag, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          // Floating Search & Filter Bar at top
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                GlassCard(
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: isIndo ? "Cari rute, tempat, area..." : "Search routes, trails, areas...",
                              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const Icon(Icons.mic, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
                const SizedBox(height: 10),
                // Horizontal category chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(isIndo ? "Semua Rute" : "All Trails", true),
                      const SizedBox(width: 8),
                      _buildFilterChip(isIndo ? "Terdekat" : "Nearby", false),
                      const SizedBox(width: 8),
                      _buildFilterChip("CFD", false),
                      const SizedBox(width: 8),
                      _buildFilterChip(isIndo ? "Tantangan" : "Challenges", false),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              ],
            ),
          ),

          // Popular Trails overlay card at bottom
          Positioned(
            bottom: 110, // Floating above the tab bar
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedRouteName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _clearRoute,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.red.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.close, color: Colors.red, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                isIndo ? "Hapus Rute" : "Clear Route",
                                style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                
                Text(
                  isIndo ? "Rute Lari Terpopuler" : "Popular Run Routes",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 10, offset: Offset(2, 2)),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 10),
                SizedBox(
                  height: 115,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _popularTrails.length,
                    itemBuilder: (context, index) {
                      final trail = _popularTrails[index];
                      final isSelected = _selectedRouteName == trail["name"];

                      return GestureDetector(
                        onTap: () => _selectRoute(trail),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 260,
                          margin: const EdgeInsets.only(right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              children: [
                                // Background blur or image
                                Container(
                                  color: Colors.black.withOpacity(0.85),
                                ),
                                // Gradient highlight
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              trail["name"],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isSelected ? AppColors.primary : Colors.white10,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              trail["difficulty"],
                                              style: TextStyle(
                                                color: isSelected ? Colors.black : Colors.white70,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          _buildRouteStat(FontAwesomeIcons.route, trail["distance"]),
                                          const SizedBox(width: 16),
                                          _buildRouteStat(FontAwesomeIcons.arrowTrendUp, trail["elevation"]),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
              ],
            ),
          ),

          // Center user button
          Positioned(
            right: 20,
            bottom: 250,
            child: FloatingActionButton(
              onPressed: () {
                _mapController.move(_currentCenter, _zoomLevel);
              },
              backgroundColor: Colors.black.withOpacity(0.8),
              foregroundColor: AppColors.primary,
              shape: const CircleBorder(side: BorderSide(color: AppColors.primary, width: 1.5)),
              child: const Icon(Icons.my_location),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? AppColors.primary : Colors.white24,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.black : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRouteStat(IconData icon, String value) {
    return Row(
      children: [
        FaIcon(icon, color: AppColors.primary, size: 12),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
