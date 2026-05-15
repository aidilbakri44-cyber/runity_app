import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/user_profile.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(UserProfile(
    isSetup: false,
    name: "New Runner",
    avatarUrl: "",
    bio: "",
    level: 1,
    xp: 0,
    nextLevelXp: 1000,
    totalDistance: 0.0,
    totalRuns: 0,
    streakDays: 0,
  )) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final box = await Hive.openBox('profile_box');
    if (box.containsKey('user_data')) {
      final data = Map<String, dynamic>.from(box.get('user_data'));
      state = UserProfile(
        isSetup: data['isSetup'] ?? false,
        name: data['name'] ?? "New Runner",
        avatarUrl: data['avatarUrl'] ?? "",
        bio: data['bio'] ?? "",
        level: data['level'] ?? 1,
        xp: data['xp'] ?? 0,
        nextLevelXp: data['nextLevelXp'] ?? 1000,
        totalDistance: (data['totalDistance'] ?? 0.0).toDouble(),
        totalRuns: data['totalRuns'] ?? 0,
        streakDays: data['streakDays'] ?? 0,
      );
    }
  }

  Future<void> _saveProfile() async {
    final box = await Hive.openBox('profile_box');
    await box.put('user_data', {
      'isSetup': state.isSetup,
      'name': state.name,
      'avatarUrl': state.avatarUrl,
      'bio': state.bio,
      'level': state.level,
      'xp': state.xp,
      'nextLevelXp': state.nextLevelXp,
      'totalDistance': state.totalDistance,
      'totalRuns': state.totalRuns,
      'streakDays': state.streakDays,
    });
  }

  void updateName(String name) {
    state = state.copyWith(name: name, isSetup: true);
    _saveProfile();
  }

  void updateAvatar(String url) {
    state = state.copyWith(avatarUrl: url);
    _saveProfile();
  }

  void updateBio(String bio) {
    state = state.copyWith(bio: bio);
    _saveProfile();
  }

  void updateProfile({String? name, String? bio, String? avatarUrl}) {
    state = state.copyWith(
      name: name ?? state.name,
      bio: bio ?? state.bio,
      avatarUrl: avatarUrl ?? state.avatarUrl,
      isSetup: true,
    );
    _saveProfile();
  }

  void completeSetup() {
    state = state.copyWith(isSetup: true);
    _saveProfile();
  }

  Future<void> logout() async {
    state = UserProfile(
      isSetup: false,
      name: "New Runner",
      avatarUrl: "",
      bio: "",
      level: 1,
      xp: 0,
      nextLevelXp: 1000,
      totalDistance: 0.0,
      totalRuns: 0,
      streakDays: 0,
    );
    final box = await Hive.openBox('profile_box');
    await box.clear();
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier();
});
