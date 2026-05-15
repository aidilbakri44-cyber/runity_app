import 'package:latlong2/latlong.dart';

import '../../presentation/providers/history_provider.dart';

enum TrackingStatus { idle, searching, running, paused, stopped }

class TrackingState {
  final TrackingStatus status;
  final double distance; // in meters
  final Duration duration;
  final double currentPace; // minutes per km
  final double currentSpeed; // m/s
  final List<LatLng> route;
  final LatLng? lastPosition;
  final SportType activityType;

  TrackingState({
    this.status = TrackingStatus.idle,
    this.distance = 0.0,
    this.duration = Duration.zero,
    this.currentPace = 0.0,
    this.currentSpeed = 0.0,
    this.route = const [],
    this.lastPosition,
    this.activityType = SportType.run,
  });

  TrackingState copyWith({
    TrackingStatus? status,
    double? distance,
    Duration? duration,
    double? currentPace,
    double? currentSpeed,
    List<LatLng>? route,
    LatLng? lastPosition,
    SportType? activityType,
  }) {
    return TrackingState(
      status: status ?? this.status,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      currentPace: currentPace ?? this.currentPace,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      route: route ?? this.route,
      lastPosition: lastPosition ?? this.lastPosition,
      activityType: activityType ?? this.activityType,
    );
  }
  
  String get formattedDistance {
    if (distance < 1000) {
      return "${distance.toStringAsFixed(0)} m";
    }
    return "${(distance / 1000).toStringAsFixed(2)} km";
  }

  String get formattedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String get formattedPace {
    if (currentPace == 0 || currentPace.isInfinite) return "-'--\"";
    int minutes = currentPace.toInt();
    int seconds = ((currentPace - minutes) * 60).toInt();
    return "$minutes'${seconds.toString().padLeft(2, '0')}\"";
  }
}
