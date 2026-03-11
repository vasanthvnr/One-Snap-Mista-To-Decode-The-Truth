import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/home_screen.dart';
import 'screens/results_screen.dart';
import 'screens/profile_screen.dart';
import 'app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Sage Green Color Palette
  static const Color sageGreen = Color(0xFF9DC183);
  static const Color sageGreenLight = Color(0xFFC1D7B7);
  static const Color sageGreenDark = Color(0xFF7A9E5A);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: sageGreen,
        scaffoldBackgroundColor: sageGreenLight,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: sageGreen,
          primary: sageGreen,
          secondary: sageGreenDark,
          surface: sageGreenLight,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: sageGreen,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: sageGreen,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

