import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AppThemeMode { light, dark, amethyst }

class ThemeViewModel extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  AppThemeMode _currentTheme =
      AppThemeMode.dark; // Default to dark for premium look

  AppThemeMode get currentTheme => _currentTheme;

  ThemeViewModel() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final stored = await _storage.read(key: 'app_theme');
    if (stored != null) {
      _currentTheme = AppThemeMode.values.firstWhere(
        (e) => e.name == stored,
        orElse: () => AppThemeMode.dark,
      );
      notifyListeners();
    }
  }

  Future<void> setTheme(AppThemeMode theme) async {
    _currentTheme = theme;
    await _storage.write(key: 'app_theme', value: theme.name);
    notifyListeners();
  }

  ThemeData getThemeData() {
    switch (_currentTheme) {
      case AppThemeMode.light:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          primaryColor: const Color.fromARGB(255, 42, 128, 162),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 13, 61, 220),
            brightness: Brightness.light,
            surface: const Color(0xFFF7F2FA),
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F2FA),
        );
      case AppThemeMode.dark:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFD0BCFF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD0BCFF),
            brightness: Brightness.dark,
            surface: const Color(0xFF141218),
            background: const Color(0xFF141218),
          ),
          scaffoldBackgroundColor: const Color(0xFF141218),
        );
      case AppThemeMode.amethyst:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFA855F7),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFA855F7),
            secondary: Color(0xFFEC4899),
            surface: Color(0xFF0F0B1E),
            background: Color(0xFF0B0616),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFF0B0616),
        );
    }
  }
}
