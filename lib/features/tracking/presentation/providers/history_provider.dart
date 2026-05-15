import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

enum SportType {
  run,
  cycle,
  swim,
  hike,
  walk;

  String get name {
    switch (this) {
      case SportType.run: return "Run";
      case SportType.cycle: return "Cycle";
      case SportType.swim: return "Swim";
      case SportType.hike: return "Hike";
      case SportType.walk: return "Walk";
    }
  }

  IconData get icon {
    switch (this) {
      case SportType.run: return FontAwesomeIcons.personRunning;
      case SportType.cycle: return FontAwesomeIcons.bicycle;
      case SportType.swim: return FontAwesomeIcons.personSwimming;
      case SportType.hike: return FontAwesomeIcons.personHiking;
      case SportType.walk: return FontAwesomeIcons.personWalking;
    }
  }
}

class Activity {
  final DateTime date;
  final double distance;
  final Duration duration;
  final String pace;
  final SportType type;
  final List<LatLng> route;

  Activity({
    required this.date,
    required this.distance,
    required this.duration,
    required this.pace,
    this.type = SportType.run,
    this.route = const [],
  });
}

// Keep the old name for backward compatibility during migration if needed, 
// but we'll refactor all usages.
typedef RunActivity = Activity;

class TrackingHistoryNotifier extends StateNotifier<List<Activity>> {
  TrackingHistoryNotifier() : super([]);

  void addActivity(Activity activity) {
    state = [activity, ...state];
  }
  
  // Alias for backward compatibility
  void addRun(Activity run) => addActivity(run);
}

final trackingHistoryProvider = StateNotifierProvider<TrackingHistoryNotifier, List<Activity>>((ref) {
  return TrackingHistoryNotifier();
});
