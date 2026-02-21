import 'package:shared_preferences/shared_preferences.dart';
import 'package:pantryready/models/user_preferences.dart';

class UserPreferencesService {
  static const String _familySizeKey = 'family_size';
  static const String _targetDaysKey = 'target_days_of_supply';

  Future<UserPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPreferences(
      familySize: prefs.getInt(_familySizeKey) ?? 1,
      targetDaysOfSupply: prefs.getInt(_targetDaysKey) ?? 30,
    );
  }

  Future<void> save(UserPreferences prefs) async {
    final shared = await SharedPreferences.getInstance();
    await shared.setInt(_familySizeKey, prefs.familySize);
    await shared.setInt(_targetDaysKey, prefs.targetDaysOfSupply);
  }
}
