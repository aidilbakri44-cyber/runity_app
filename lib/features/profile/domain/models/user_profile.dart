class UserProfile {
  final String name;
  final String avatarUrl;
  final int level;
  final int xp;
  final int nextLevelXp;
  final double totalDistance;
  final int totalRuns;
  final int streakDays;

  UserProfile({
    required this.name,
    required this.avatarUrl,
    required this.level,
    required this.xp,
    required this.nextLevelXp,
    required this.totalDistance,
    required this.totalRuns,
    required this.streakDays,
  });
}
