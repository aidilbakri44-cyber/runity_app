import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/utils/image_helper.dart';
import '../providers/tracking_provider.dart';
import '../providers/history_provider.dart';
import 'save_success_card_page.dart';

class SaveActivityPage extends ConsumerStatefulWidget {
  const SaveActivityPage({super.key});

  @override
  ConsumerState<SaveActivityPage> createState() => _SaveActivityPageState();
}

class _SaveActivityPageState extends ConsumerState<SaveActivityPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _privateNotesController = TextEditingController();

  SportType? _selectedSport;
  String? _selectedRunType;
  String? _selectedFeeling;
  String? _pickedImagePath;

  int _currentMapStyleIndex = 0;

  final List<Map<String, String>> _mapStyles = [
    {
      'name': 'Dark Matter',
      'url': 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
    },
    {
      'name': 'Standard',
      'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    },
    {
      'name': 'Positron (Light)',
      'url': 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
    },
    {
      'name': 'Topografi',
      'url': 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
    },
  ];

  // List of feeling options in English and Indonesian
  final List<Map<String, String>> _feelingOptions = [
    {'en': 'Very Easy', 'id': 'Sangat Mudah'},
    {'en': 'Easy', 'id': 'Mudah'},
    {'en': 'Moderate', 'id': 'Sedang'},
    {'en': 'Hard', 'id': 'Sulit'},
    {'en': 'Very Hard', 'id': 'Sangat Sulit'},
  ];

  // List of run type options
  final List<Map<String, String>> _runTypeOptions = [
    {'en': 'General Run', 'id': 'Lari Biasa'},
    {'en': 'Marathon', 'id': 'Lari Maraton'},
    {'en': 'Intervals', 'id': 'Lari Interval'},
    {'en': 'Tempo', 'id': 'Lari Tempo'},
    {'en': 'Recovery', 'id': 'Lari Santai'},
  ];

  // Mock route for preview fallback (Sudirman loop coordinates)
  final List<LatLng> _mockRoute = [
    const LatLng(-6.200000, 106.816666),
    const LatLng(-6.205000, 106.819000),
    const LatLng(-6.215000, 106.818000),
    const LatLng(-6.220000, 106.810000),
    const LatLng(-6.210000, 106.805000),
    const LatLng(-6.200000, 106.816666),
  ];

  @override
  void initState() {
    super.initState();
    // Default fallback values initialized in didChangeDependencies or post frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(trackingProvider);
      setState(() {
        _selectedSport = state.activityType;
        final settings = ref.read(settingsProvider);
        final isIndo = settings.language == 'Bahasa Indonesia';
        _titleController.text = _getDefaultTitle(state.activityType, isIndo);
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _privateNotesController.dispose();
    super.dispose();
  }

  String _getDefaultTitle(SportType type, bool isIndo) {
    final now = DateTime.now();
    final hour = now.hour;
    String timeOfDay = isIndo ? "Aktivitas" : "Activity";

    if (hour >= 4 && hour < 11) {
      timeOfDay = isIndo ? "Pagi" : "Morning";
    } else if (hour >= 11 && hour < 15) {
      timeOfDay = isIndo ? "Siang" : "Midday";
    } else if (hour >= 15 && hour < 18) {
      timeOfDay = isIndo ? "Sore" : "Afternoon";
    } else {
      timeOfDay = isIndo ? "Malam" : "Evening";
    }

    switch (type) {
      case SportType.run:
        return isIndo ? "Lari $timeOfDay" : "$timeOfDay Run";
      case SportType.cycle:
        return isIndo ? "Sepeda $timeOfDay" : "$timeOfDay Ride";
      case SportType.walk:
        return isIndo ? "Jalan $timeOfDay" : "$timeOfDay Walk";
      case SportType.hike:
        return isIndo ? "Daki $timeOfDay" : "$timeOfDay Hike";
      case SportType.swim:
        return isIndo ? "Renang $timeOfDay" : "$timeOfDay Swim";
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pickedImagePath = image.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _pickedImagePath = null;
    });
  }

  Future<bool> _onWillPop() async {
    final settings = ref.read(settingsProvider);
    String t(String key) => AppTranslations.translate(settings.language, key);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          t('discard_dialog_title'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          t('discard_dialog_desc'),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('cancel'), style: const TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('discard'), style: const TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );

    if (result == true) {
      ref.read(trackingProvider.notifier).reset();
    }
    return result ?? false;
  }

  void _saveActivity() {
    final trackingState = ref.read(trackingProvider);
    
    final finalDistance = trackingState.distance / 1000; // in km
    final finalDuration = trackingState.duration;
    final finalPace = trackingState.formattedPace;
    final finalRoute = trackingState.route;

    final newActivity = Activity(
      date: DateTime.now(),
      distance: finalDistance,
      duration: finalDuration,
      pace: finalPace,
      type: _selectedSport ?? SportType.run,
      route: finalRoute,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      runType: _selectedRunType,
      feeling: _selectedFeeling,
      privateNotes: _privateNotesController.text.trim(),
      photoPath: _pickedImagePath,
      heartRate: trackingState.heartRate,
    );

    // Save to history
    ref.read(trackingHistoryProvider.notifier).addActivity(newActivity);
    
    // Reset tracker
    ref.read(trackingProvider.notifier).reset();

    // Navigate to success card page (replaces SaveActivityPage in stack)
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SaveSuccessCardPage(activity: newActivity),
        ),
      );
    }
  }

  void _changeMapStyle() {
    setState(() {
      _currentMapStyleIndex = (_currentMapStyleIndex + 1) % _mapStyles.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isIndo = settings.language == 'Bahasa Indonesia';
    String t(String key) => AppTranslations.translate(settings.language, key);
    final trackingState = ref.watch(trackingProvider);

    final cyanThemeColor = const Color(0xFF00E5FF);
    final orangeThemeColor = const Color(0xFF00A2FF); // Blue for photo and map buttons
    final fieldBgColor = const Color(0xFF1C1C1E); // Darker grey for fields
    final formFieldBorderColor = Colors.transparent;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            t('save_activity'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: _saveActivity,
              child: Text(
                t('save'),
                style: TextStyle(
                  color: cyanThemeColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: _selectedSport != null 
                      ? t('title_placeholder_${_selectedSport!.name}') 
                      : t('title_placeholder_generic'),
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 16),
                  filled: true,
                  fillColor: fieldBgColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: formFieldBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cyanThemeColor),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Description Field
              TextFormField(
                controller: _descController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: t('desc_placeholder'),
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 14, height: 1.4),
                  filled: true,
                  fillColor: fieldBgColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: formFieldBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cyanThemeColor),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Sport Selector Row/Button
              GestureDetector(
                onTap: () => _showSportPickerBottomSheet(context, isIndo),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: fieldBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: formFieldBorderColor),
                  ),
                  child: Row(
                    children: [
                      FaIcon(
                        _selectedSport?.icon ?? FontAwesomeIcons.personRunning,
                        color: cyanThemeColor,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedSport != null 
                            ? (isIndo ? _getSportNameIndo(_selectedSport!) : _selectedSport!.name)
                            : (isIndo ? "Pilih Olahraga" : "Select Sport"),
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Media / Map Section Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map Preview (Left Side)
                  Expanded(
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: formFieldBorderColor),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: trackingState.route.isNotEmpty
                                  ? trackingState.route[trackingState.route.length ~/ 2]
                                  : _mockRoute[_mockRoute.length ~/ 2],
                              initialZoom: 14.2,
                              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: _mapStyles[_currentMapStyleIndex]['url']!,
                                userAgentPackageName: 'com.runity.app',
                              ),
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: trackingState.route.isNotEmpty ? trackingState.route : _mockRoute,
                                    color: cyanThemeColor,
                                    strokeWidth: 4,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Static Overlay Text if fallback
                          if (trackingState.route.isEmpty)
                            Container(
                              color: Colors.black.withOpacity(0.55),
                              padding: const EdgeInsets.all(8),
                              child: Center(
                                child: Text(
                                  t('sample_map_desc'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Image Upload Container (Right Side)
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickedImagePath == null ? _pickImage : null,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: fieldBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            if (_pickedImagePath == null)
                              CustomPaint(
                                painter: DashedBorderPainter(
                                  color: orangeThemeColor,
                                  strokeWidth: 1.5,
                                  borderRadius: 12,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        color: orangeThemeColor,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        t('add_photo_video'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: orangeThemeColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ImageHelper.imageFromPath(
                                      _pickedImagePath!,
                                      fit: BoxFit.cover,
                                    ),
                                    // Remove button overlay
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: GestureDetector(
                                        onTap: _removeImage,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Change Map Type Button (orange border)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _changeMapStyle,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: orangeThemeColor, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.layers_outlined, color: orangeThemeColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        t('change_map_type'),
                        style: TextStyle(color: orangeThemeColor, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Rincian Section Title
              Text(
                t('details'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 12),

              // Jenis Lari Dropdown
              GestureDetector(
                onTap: () => _showRunTypePickerBottomSheet(context, isIndo),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: fieldBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: formFieldBorderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white54,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedRunType ?? t('run_type'),
                        style: TextStyle(
                          color: _selectedRunType != null ? Colors.white : Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Feeling Dropdown
              GestureDetector(
                onTap: () => _showFeelingPickerBottomSheet(context, isIndo),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: fieldBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: formFieldBorderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sentiment_satisfied_alt,
                        color: Colors.white54,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedFeeling ?? t('how_feel'),
                        style: TextStyle(
                          color: _selectedFeeling != null ? Colors.white : Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Private Notes field
              TextFormField(
                controller: _privateNotesController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: t('private_notes'),
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54, size: 18),
                  filled: true,
                  fillColor: fieldBgColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: formFieldBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cyanThemeColor),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  String _getSportNameIndo(SportType type) {
    switch (type) {
      case SportType.run: return "Berlari";
      case SportType.cycle: return "Bersepeda";
      case SportType.walk: return "Berjalan";
      case SportType.hike: return "Mendaki";
      case SportType.swim: return "Berenang";
    }
  }

  void _showSportPickerBottomSheet(BuildContext context, bool isIndo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  isIndo ? "Pilih Jenis Olahraga" : "Select Sport Type",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.white10),
              ...SportType.values.map((type) {
                final name = isIndo ? _getSportNameIndo(type) : type.name;
                return ListTile(
                  leading: FaIcon(type.icon, color: AppColors.primary, size: 18),
                  title: Text(name, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      _selectedSport = type;
                      // Update default title if user hasn't typed anything
                      if (_titleController.text.isEmpty || 
                          _titleController.text == _getDefaultTitle(SportType.run, isIndo) ||
                          _titleController.text == _getDefaultTitle(SportType.cycle, isIndo) ||
                          _titleController.text == _getDefaultTitle(SportType.walk, isIndo) ||
                          _titleController.text == _getDefaultTitle(SportType.hike, isIndo) ||
                          _titleController.text == _getDefaultTitle(SportType.swim, isIndo)) {
                        _titleController.text = _getDefaultTitle(type, isIndo);
                      }
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showRunTypePickerBottomSheet(BuildContext context, bool isIndo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  isIndo ? "Pilih Jenis Lari" : "Select Run Type",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.white10),
              ..._runTypeOptions.map((opt) {
                final display = isIndo ? opt['id']! : opt['en']!;
                return ListTile(
                  title: Text(display, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      _selectedRunType = display;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showFeelingPickerBottomSheet(BuildContext context, bool isIndo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  isIndo ? "Bagaimana Rasanya?" : "How Did It Feel?",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.white10),
              ..._feelingOptions.map((opt) {
                final display = isIndo ? opt['id']! : opt['en']!;
                return ListTile(
                  title: Text(display, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      _selectedFeeling = display;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
    this.dashLength = 6.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = ui.Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashPath = _buildDashPath(path, dashLength, gap);
    canvas.drawPath(dashPath, paint);
  }

  ui.Path _buildDashPath(ui.Path source, double dashLength, double gap) {
    final ui.Path dest = ui.Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dashLength : gap;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, (distance + length).clamp(0.0, metric.length)),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
