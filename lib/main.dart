import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/secure_storage_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/card_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'views/login_view.dart';
import 'views/main_navigation_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = SecureStorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => CardViewModel(storageService),
        ),
      ],
      child: const MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    return MaterialApp(
      title: 'TessereApp',
      debugShowCheckedModeBanner: false,
      theme: themeViewModel.getThemeData(),
      home: authViewModel.isAuthenticated ? const MainNavigationView() : const LoginView(),
    );
  }
}
