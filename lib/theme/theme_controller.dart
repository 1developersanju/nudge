import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists [ThemeMode] (system / light / dark) in [SharedPreferences].
class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode_v1';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get themeMode => _mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final i = prefs.getInt(_key);
    if (i != null && i >= 0 && i < ThemeMode.values.length) {
      _mode = ThemeMode.values[i];
    } else {
      _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _mode.index);
  }
}
