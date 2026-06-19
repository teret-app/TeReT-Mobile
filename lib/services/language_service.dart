import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static final ValueNotifier<String> currentLanguage =
  ValueNotifier<String>('hr');

  static const String _languageKey = 'selected_language';

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage == 'hr' ||
        savedLanguage == 'en' ||
        savedLanguage == 'de') {
      currentLanguage.value = savedLanguage!;
    }
  }

  static Future<void> setLanguage(String code) async {
    if (code != 'hr' && code != 'en' && code != 'de') return;

    currentLanguage.value = code;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }

  static String get language => currentLanguage.value;

  static String text({
    required String hr,
    required String en,
    required String de,
  }) {
    if (currentLanguage.value == 'en') return en;
    if (currentLanguage.value == 'de') return de;
    return hr;
  }
}