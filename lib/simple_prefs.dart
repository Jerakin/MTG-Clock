import 'package:shared_preferences/shared_preferences.dart';

class SimplePrefs {
  static SharedPreferences? _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static int? getPlayerCount() => _preferences?.getInt("playerCount");

  static int? getSelectedTimer() => _preferences?.getInt("selectedTimer");

  static int? getPerPlayerTimeLimit() =>
      _preferences?.getInt("perPlayerTimeLimit");

  static int? getTournamentTimeLimit() =>
      _preferences?.getInt("perTournamentTimeLimit");

  static Future setPlayerCount(int v) async =>
      await _preferences?.setInt("playerCount", v);

  static Future setSelectedTimer(int v) async =>
      await _preferences?.setInt("selectedTimer", v);

  static Future setPerPlayerTimeLimit(int v) async =>
      await _preferences?.setInt("perPlayerTimeLimit", v);

  static Future setTournamentTimeLimit(int v) async =>
      await _preferences?.setInt("perTournamentTimeLimit", v);
}
