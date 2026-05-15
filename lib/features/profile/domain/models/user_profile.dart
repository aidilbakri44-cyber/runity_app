class UserProfile {
  final bool isSetup;
  final String name;
  final String avatarUrl;
  final String bio;
  final int level;
  final int xp;
  final int nextLevelXp;
  final double totalDistance;
  final int totalRuns;
  final int streakDays;

  UserProfile({
    this.isSetup = false,
    required this.name,
    required this.avatarUrl,
    this.bio = "",
    required this.level,
    required this.xp,
    required this.nextLevelXp,
    required this.totalDistance,
    required this.totalRuns,
    required this.streakDays,
  });

  UserProfile copyWith({
    bool? isSetup,
    String? name,
    String? avatarUrl,
    String? bio,
    int? level,
    int? xp,
    int? nextLevelXp,
    double? totalDistance,
    int? totalRuns,
    int? streakDays,
  }) {
    return UserProfile(
      isSetup: isSetup ?? this.isSetup,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
      totalDistance: totalDistance ?? this.totalDistance,
      totalRuns: totalRuns ?? this.totalRuns,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}
