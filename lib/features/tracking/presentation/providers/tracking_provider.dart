import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
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
    state = state.copyWith(status: TrackingStatus.running);
    _startTimer();

    if (kIsWeb) {
      _startSimulation();
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _startSimulation();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _startSimulation();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _startSimulation();
      return;
    }

    try {
      final initialPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _updateLocation(initialPosition);
    } catch (e) {
      // Ignored, stream will catch it later
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      _updateLocation(position);
    });
  }

  void _startSimulation() {
    _positionStream?.cancel();
    
    // Initial dummy position (Jakarta)
    LatLng currentPos = const LatLng(-6.200000, 106.816666);
    if (state.lastPosition != null) {
      currentPos = state.lastPosition!;
    }
    
    // Simulate walking/running
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (state.status != TrackingStatus.running) {
        timer.cancel();
        return;
      }
      
      final speed = state.activityType == SportType.cycle ? 0.00015 : 0.00005;
      final newLat = currentPos.latitude + (math.Random().nextDouble() - 0.2) * speed;
      final newLng = currentPos.longitude + (math.Random().nextDouble() - 0.2) * speed;
      
      currentPos = LatLng(newLat, newLng);
      
      // Mock a Position object
      final mockPosition = Position(
        longitude: currentPos.longitude,
        latitude: currentPos.latitude,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 10.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: speed * 100000,
        speedAccuracy: 1.0,
      );
      
      _updateLocation(mockPosition);
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
    if (_positionStream != null && _positionStream!.isPaused) {
      _positionStream!.resume();
    } else if (kIsWeb || _positionStream == null) {
      _startSimulation();
    }
    state = state.copyWith(status: TrackingStatus.running);
  }

  void stopTracking({bool saveToHistory = false}) {
    _timer?.cancel();
    _positionStream?.cancel();
    
    if (saveToHistory && state.distance > 0) {
      _historyNotifier.addActivity(Activity(
        date: DateTime.now(),
        distance: state.distance / 1000,
        duration: state.duration,
        pace: state.formattedPace,
        type: state.activityType,
        route: List.from(state.route),
      ));
    }
    
    state = state.copyWith(status: TrackingStatus.stopped);
  }

  void setActivityType(SportType type) {
    state = state.copyWith(activityType: type);
  }

  void setSettings({bool? autoPause, bool? audioCues}) {
    state = state.copyWith(autoPause: autoPause, audioCues: audioCues);
  }

  void setHeartRate(int bpm) {
    state = state.copyWith(heartRate: bpm);
  }

  void reset() {
    SportType currentType = state.activityType;
    _timer?.cancel();
    _positionStream?.cancel();
    state = TrackingState(activityType: currentType);
  }
}
