import 'package:flutter/material.dart';

/// Provider for managing the application's language/locale.
///
/// Allows switching between supported locales and notifies listeners on change.
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(String languageCode) {
    _locale = Locale(languageCode);
    notifyListeners();
  }
}
