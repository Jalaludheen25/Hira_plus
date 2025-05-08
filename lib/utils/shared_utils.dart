import 'package:shared_preferences/shared_preferences.dart';

class SharedUtils {
  static late SharedPreferences sharedPreferences;

  static setString(String key, String value) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, value);
  }

  static setBoolean(String key, bool value) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(key, value);
  }

  static setInt(String key, int value) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(key, value);
  }

  static getString(String key) async {
    sharedPreferences = await SharedPreferences.getInstance();
    return (sharedPreferences.getString(key) ?? '');
  }

  static getBoolean(String key) async {
    sharedPreferences = await SharedPreferences.getInstance();
    return (sharedPreferences.getBool(key) ?? false);
  }

  static getInt(String key) async {
    sharedPreferences = await SharedPreferences.getInstance();
    return (sharedPreferences.getInt(key) ?? 0);
  }
}
