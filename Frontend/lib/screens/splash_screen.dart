import 'dart:async';
import 'package:flutter/material.dart';
import '../app_routes.dart';
import '../main.dart';
import '../services/local_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if user is logged in
    final isLoggedIn = await LocalStorageService.isLoggedIn();
    
    if (mounted) {
      if (isLoggedIn) {
        // User is logged in, go to home
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        // User is not logged in, go to login
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.sageGreenLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: MyApp.sageGreen.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Image.asset('assets/LOGO.png', width: 120, height: 120),
            ),
            const SizedBox(height: 30),
            const Text(
              'Health Care',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: MyApp.sageGreenDark,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your Health, Our Priority',
              style: TextStyle(
                fontSize: 14,
                color: MyApp.sageGreen.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
