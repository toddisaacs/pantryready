class UserPreferences {
  final int familySize;
  final int targetDaysOfSupply;

  const UserPreferences({this.familySize = 1, this.targetDaysOfSupply = 30});

  UserPreferences copyWith({int? familySize, int? targetDaysOfSupply}) {
    return UserPreferences(
      familySize: familySize ?? this.familySize,
      targetDaysOfSupply: targetDaysOfSupply ?? this.targetDaysOfSupply,
    );
  }
}
