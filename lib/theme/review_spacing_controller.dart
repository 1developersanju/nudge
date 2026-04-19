import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/prefs_keys.dart';
import '../domain/scheduling_profile.dart';
import '../domain/spacing_config_codec.dart';

/// Persists global spaced-repetition **wave delays** (three revisits after capture).
class ReviewSpacingController extends ChangeNotifier {
  ReviewSpacingController();

  static const _key = PrefsKeys.spacingConfig;

  SchedulingProfile _profile = SchedulingProfile.production;
  String _preset = 'production';
  List<int>? _customMinutes;

  SchedulingProfile get profile => _profile;

  /// `production`, `test`, or `custom`.
  String get presetId => _customMinutes != null ? 'custom' : _preset;

  List<int>? get customMinutes =>
      _customMinutes == null ? null : List<int>.from(_customMinutes!);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    _profile = SpacingConfigCodec.decode(raw);
    _preset = 'production';
    _customMinutes = null;
    if (raw != null && raw.isNotEmpty) {
      try {
        final o = jsonDecode(raw) as Map<String, dynamic>;
        if (o['m'] is List) {
          final list = (o['m'] as List).map((e) => (e as num).toInt()).toList();
          if (SchedulingProfile.isValidCustomMinutesList(list)) {
            _customMinutes = list;
          }
        } else {
          _preset = (o['p'] as String?) == 'test' ? 'test' : 'production';
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> setPreset(String id) async {
    final normalized = id == 'test' ? 'test' : 'production';
    _preset = normalized;
    _customMinutes = null;
    _profile = normalized == 'test'
        ? SchedulingProfile.test
        : SchedulingProfile.production;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({'p': normalized}));
  }

  Future<void> setCustomMinutes(List<int> minutes) async {
    if (!SchedulingProfile.isValidCustomMinutesList(minutes)) return;
    _profile = SchedulingProfile.fromCustomMinutes(minutes);
    _customMinutes = List<int>.from(minutes);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({'m': minutes}));
  }
}
