import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class ResponsiveWrapper extends StatefulWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  State<ResponsiveWrapper> createState() => _ResponsiveWrapperState();
}

class _ResponsiveWrapperState extends State<ResponsiveWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If it's a mobile device (Android/iOS) running as an app, just return the child
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      return widget.child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Threshold for desktop/web
        if (screenWidth > 600) {
          final isVeryLarge = screenHeight > 850;
          final frameWidth = 400.0;
          final frameHeight = isVeryLarge ? 850.0 : screenHeight * 0.95;

          return Scaffold(
            backgroundColor: const Color(0xFF0D0D0D),
            body: Stack(
              children: [
                // Animated glowing background
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Positioned(
                      left: screenWidth / 2 - 400 + math.sin(_controller.value * 2 * math.pi) * 100,
                      top: screenHeight / 2 - 400 + math.cos(_controller.value * 2 * math.pi) * 100,
                      child: Container(
                        width: 800,
                        height: 800,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF00E5FF).withValues(alpha: 0.05),
                              const Color(0xFFC4FF00).withValues(alpha: 0.03),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Centered Phone Frame
                Center(
                  child: Container(
                    width: frameWidth,
                    height: frameHeight,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: const Color(0xFF333333),
                        width: 8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                          blurRadius: 100,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Stack(
                        children: [
                          widget.child,
                          // Fake Dynamic Island / Notch
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: 120,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Return normal child on small screens
        return widget.child;
      },
    );
  }
}
