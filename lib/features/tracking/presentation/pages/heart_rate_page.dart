import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';

class HeartRatePage extends StatefulWidget {
  const HeartRatePage({super.key});

  @override
  State<HeartRatePage> createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage>
    with SingleTickerProviderStateMixin {
  bool _done = false;
  int _bpm = 0;
  int _progress = 0; // 0-100
  Timer? _timer;
  final List<int> _bpmReadings = [];
  late AnimationController _pulseController;

  bool _fingerPresent = false;
  int _ticks = 0;
  static const int _totalTicks = 15; // 15 * 200ms = 3s

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _onFingerDown() {
    if (_done) return;
    setState(() {
      _fingerPresent = true;
    });
    _pulseController.repeat(reverse: true);
    _resumeTimer();
  }

  void _onFingerUp() {
    if (_done) return;
    setState(() {
      _fingerPresent = false;
    });
    _pulseController.stop();
    _pauseTimer();
  }

  void _resumeTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _ticks++;
      final rand = Random();

      // Generate realistic BPM curve
      int baseBpm = 72 + rand.nextInt(12) - 6;
      if (_ticks > 5) baseBpm = 74 + rand.nextInt(8) - 4;
      if (_ticks > 15) baseBpm = 76 + rand.nextInt(6) - 3;

      _bpmReadings.add(baseBpm);

      setState(() {
        _progress = ((_ticks / _totalTicks) * 100).round().clamp(0, 100);
        if (_bpmReadings.length > 5) {
          _bpm = (_bpmReadings.reduce((a, b) => a + b) / _bpmReadings.length).round();
        }
      });

      if (_ticks >= _totalTicks) {
        timer.cancel();
        _pulseController.stop();
        setState(() {
          _done = true;
          _fingerPresent = false;
          _bpm = (_bpmReadings.reduce((a, b) => a + b) / _bpmReadings.length).round();
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _getBpmZone(int bpm) {
    if (bpm < 60) return "Istirahat";
    if (bpm < 100) return "Normal";
    if (bpm < 140) return "Kardio Ringan";
    if (bpm < 170) return "Kardio Berat";
    return "Puncak";
  }

  Color _getBpmColor(int bpm) {
    if (bpm < 60) return AppColors.secondary;
    if (bpm < 100) return AppColors.primary;
    if (bpm < 140) return Colors.amber;
    if (bpm < 170) return Colors.orange;
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    final bpmColor = _bpm > 0 ? _getBpmColor(_bpm) : AppColors.accent;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // === Dynamic Background Orbs ===
          // Top-left main orb
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    bpmColor.withOpacity(_fingerPresent ? 0.18 : 0.06),
                    bpmColor.withOpacity(_fingerPresent ? 0.06 : 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(
               begin: const Offset(1, 1),
               end: const Offset(1.25, 1.25),
               duration: 4.seconds,
               curve: Curves.easeInOut,
             ),
          ),
          // Center-right orb
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withOpacity(_fingerPresent ? 0.12 : 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(
               begin: const Offset(0.9, 0.9),
               end: const Offset(1.2, 1.2),
               duration: 5.seconds,
               curve: Curves.easeInOut,
             )
             .moveX(begin: 0, end: 15, duration: 5.seconds, curve: Curves.easeInOut),
          ),
          // Bottom-left orb
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(_fingerPresent ? 0.14 : 0.05),
                    AppColors.accent.withOpacity(0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(
               begin: const Offset(1, 1),
               end: const Offset(1.15, 1.15),
               duration: 3.5.seconds,
               curve: Curves.easeInOut,
             ),
          ),
          // Bottom-right orb
          Positioned(
            bottom: -40,
            right: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C4DFF).withOpacity(_fingerPresent ? 0.10 : 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(
               begin: const Offset(1.05, 1.05),
               end: const Offset(1.3, 1.3),
               duration: 4.5.seconds,
               curve: Curves.easeInOut,
             ),
          ),
          // Small accent orb near center
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    bpmColor.withOpacity(_fingerPresent ? 0.10 : 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .moveY(begin: -10, end: 10, duration: 3.seconds, curve: Curves.easeInOut)
             .scale(
               begin: const Offset(0.95, 0.95),
               end: const Offset(1.1, 1.1),
               duration: 3.seconds,
               curve: Curves.easeInOut,
             ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context, _done ? _bpm : null),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white54, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Detak Jantung",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Heart Icon + BPM
                _buildHeartDisplay(bpmColor),

                const Spacer(),

                // Progress or Zone Info
                if (!_done) _buildProgressSection(bpmColor),
                if (_done) _buildResultSection(bpmColor),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartDisplay(Color bpmColor) {
    return Column(
      children: [
        // Pulsing heart container
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = _fingerPresent
                ? 1.0 + (_pulseController.value * 0.12)
                : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bpmColor.withOpacity(0.08),
                  border: Border.all(
                    color: bpmColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.heartPulse,
                    color: bpmColor,
                    size: 56,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // BPM Value
        if (_bpm > 0 && (_fingerPresent || _done))
          Text(
            "$_bpm",
            style: TextStyle(
              color: bpmColor,
              fontSize: 80,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ).animate().fadeIn(duration: 300.ms)
        else
          Text(
            _done
                ? "---"
                : (_fingerPresent ? "Mengukur..." : "Tahan Jari..."),
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          "BPM",
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildFingerprintScanner(Color bpmColor) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Listener(
          onPointerDown: (_) => _onFingerDown(),
          onPointerUp: (_) => _onFingerUp(),
          onPointerCancel: (_) => _onFingerUp(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _fingerPresent
                ? Container(
                    key: const ValueKey('active_fingerprint'),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bpmColor.withOpacity(0.2),
                      border: Border.all(
                        color: bpmColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.fingerprint,
                      color: bpmColor,
                      size: 60,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 800.ms,
                    curve: Curves.easeInOut,
                  )
                : Container(
                    key: const ValueKey('inactive_fingerprint'),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(
                        color: Colors.white24,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      color: Colors.white54,
                      size: 60,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _fingerPresent ? "SENSOR AKTIF" : "SIAP MENERIMA SENSOR",
          style: TextStyle(
            color: _fingerPresent ? bpmColor : Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(Color bpmColor) {
    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(bpmColor),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _fingerPresent
              ? "Membaca detak jantung... Tahan jari Anda"
              : "Tempel & Tahan jari pada sidik jari untuk mengukur",
          style: TextStyle(
            color: _fingerPresent ? Colors.white.withOpacity(0.7) : Colors.amber.withOpacity(0.8),
            fontSize: 13,
            fontWeight: _fingerPresent ? FontWeight.normal : FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "$_progress%",
          style: TextStyle(
            color: bpmColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildFingerprintScanner(bpmColor),
      ],
    );
  }

  Widget _buildResultSection(Color bpmColor) {
    final zone = _getBpmZone(_bpm);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bpmColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bpmColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            "Zona: $zone",
            style: TextStyle(
              color: bpmColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat("Min", "${_bpmReadings.isNotEmpty ? _bpmReadings.reduce(min) : 0}", bpmColor),
              Container(width: 1, height: 30,
                  color: Colors.white.withOpacity(0.1)),
              _buildMiniStat("Avg", "$_bpm", bpmColor),
              Container(width: 1, height: 30,
                  color: Colors.white.withOpacity(0.1)),
              _buildMiniStat("Max", "${_bpmReadings.isNotEmpty ? _bpmReadings.reduce(max) : 0}", bpmColor),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pop(context, _done ? _bpm : null),
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bpmColor, bpmColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: bpmColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "SIMPAN & KEMBALI",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                _done = false;
                _bpm = 0;
                _progress = 0;
                _ticks = 0;
                _bpmReadings.clear();
                _fingerPresent = false;
              });
            },
            child: const Text(
              "Ukur Ulang",
              style: TextStyle(color: Colors.white54, fontSize: 12, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
