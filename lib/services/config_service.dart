// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider_android/path_provider_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';


/// Provides key-val-storage like functionalities with device storage and configurations
class ConfigService {
  static late SharedPreferences _prefs;


  static Future<void> ensureInitialized() async {
    if (!kIsWeb && Platform.isAndroid) {
      SharedPreferencesAndroid.registerWith();
      PathProviderAndroid.registerWith();
    }

    _prefs = await SharedPreferences.getInstance();
    await _prefs.reload();
    await _load();
  }

  static Future<void> _load() async {

  }

  static dynamic getCustom(String id) {
    return _prefs.get(id);
  }

  static Future<void> setCustom(String id, dynamic value) async {
    switch (value.runtimeType) {
      case bool:
        await _prefs.setBool(id, value);
        break;
      case int:
        await _prefs.setInt(id, value);
        break;
      case double:
        await _prefs.setDouble(id, value);
        break;
      default:
        await _prefs.setString(id, value);
    }
  }


}

/// A config that saves the state
class ExpandableCrossSessionConfig {
  final String id;
  bool _expanded = false;
  String get _configId => "expandable_cross_session_config_token_$id";

  ExpandableCrossSessionConfig(this.id, {bool defaultExpanded = false}) {
    _expanded = ConfigService.getCustom(_configId) ?? defaultExpanded;
  }

  bool get expanded => _expanded;

  set expanded(bool e) {
    _expanded = e;
    ConfigService.setCustom(_configId, e);
  }
}
