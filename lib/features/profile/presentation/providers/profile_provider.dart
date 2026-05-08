import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(UserProfile(
    name: "Aidil Bakri",
    avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200",
    level: 12,
    xp: 2450,
    nextLevelXp: 3000,
    totalDistance: 156.8,
    totalRuns: 42,
    streakDays: 5,
  ));

  void updateName(String name) {
    state = UserProfile(
      name: name,
      avatarUrl: state.avatarUrl,
      level: state.level,
      xp: state.xp,
      nextLevelXp: state.nextLevelXp,
      totalDistance: state.totalDistance,
      totalRuns: state.totalRuns,
      streakDays: state.streakDays,
    );
  }

  void updateAvatar(String url) {
    state = UserProfile(
      name: state.name,
      avatarUrl: url,
      level: state.level,
      xp: state.xp,
      nextLevelXp: state.nextLevelXp,
      totalDistance: state.totalDistance,
      totalRuns: state.totalRuns,
      streakDays: state.streakDays,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier();
});
