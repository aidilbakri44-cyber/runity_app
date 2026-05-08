import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/models/tracking_state.dart';

import 'history_provider.dart';

final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  final historyNotifier = ref.read(trackingHistoryProvider.notifier);
  return TrackingNotifier(historyNotifier);
});

class TrackingNotifier extends StateNotifier<TrackingState> {
  final TrackingHistoryNotifier _historyNotifier;
  TrackingNotifier(this._historyNotifier) : super(TrackingState());

  StreamSubscription<Position>? _positionStream;
  Timer? _timer;

  Future<void> startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    state = state.copyWith(status: TrackingStatus.running);
    _startTimer();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      _updateLocation(position);
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(duration: state.duration + const Duration(seconds: 1));
    });
  }

  void _updateLocation(Position position) {
    final newLatLng = LatLng(position.latitude, position.longitude);
    double addedDistance = 0;

    if (state.lastPosition != null) {
      addedDistance = Geolocator.distanceBetween(
        state.lastPosition!.latitude,
        state.lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
    }

    final newDistance = state.distance + addedDistance;
    final List<LatLng> newRoute = List.from(state.route)..add(newLatLng);

    // Calculate Pace (min/km)
    double pace = 0;
    if (newDistance > 0) {
      double km = newDistance / 1000;
      double minutes = state.duration.inSeconds / 60;
      pace = minutes / km;
    }

    state = state.copyWith(
      lastPosition: newLatLng,
      distance: newDistance,
      route: newRoute,
      currentPace: pace,
      currentSpeed: position.speed,
    );
  }

  void pauseTracking() {
    _timer?.cancel();
    _positionStream?.pause();
    state = state.copyWith(status: TrackingStatus.paused);
  }

  void resumeTracking() {
    _startTimer();
    _positionStream?.resume();
    state = state.copyWith(status: TrackingStatus.running);
  }

  void stopTracking() {
    _timer?.cancel();
    _positionStream?.cancel();
    
    if (state.distance > 0) {
      _historyNotifier.addActivity(Activity(
        date: DateTime.now(),
        distance: state.distance / 1000,
        duration: state.duration,
        pace: state.formattedPace,
        type: state.activityType,
      ));
    }
    
    state = state.copyWith(status: TrackingStatus.stopped);
  }

  void setActivityType(SportType type) {
    state = state.copyWith(activityType: type);
  }

  void reset() {
    SportType currentType = state.activityType;
    _timer?.cancel();
    _positionStream?.cancel();
    state = TrackingState(activityType: currentType);
  }
}
