import 'package:flutter/material.dart';
import '../app_routes.dart';
import '../services/local_storage_service.dart';
import '../main.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  Future<void> _registerUser(
    BuildContext context,
    String name,
    String email,
    String password,
    String healthIssues,
  ) async {
    try {
      // Use local storage for registration
      final success = await LocalStorageService.registerUser(
        name: name,
        email: email,
        password: password,
        healthIssues: healthIssues,
      );

      if (success) {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      } else {
        if (context.mounted) {
          _showErrorDialog(context, 'Email already registered');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Error: $e');
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Registration Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final healthIssuesController = TextEditingController();

    return Scaffold(
      backgroundColor: MyApp.sageGreenLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: MyApp.sageGreen),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: MyApp.sageGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Name Field
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter Name',
                  prefixIcon: const Icon(Icons.person, color: MyApp.sageGreen),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Email Field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter Email',
                  prefixIcon: const Icon(Icons.email, color: MyApp.sageGreen),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Password Field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter Password',
                  prefixIcon: const Icon(Icons.lock, color: MyApp.sageGreen),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Health Issues Field
              TextField(
                controller: healthIssuesController,
                decoration: InputDecoration(
                  labelText: 'Any Health Issues?',
                  hintText: 'e.g., Asthma, Allergy, Diabetes',
                  prefixIcon: const Icon(Icons.health_and_safety, color: MyApp.sageGreen),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyApp.sageGreen,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isEmpty ||
                        emailController.text.trim().isEmpty ||
                        passwordController.text.trim().isEmpty ||
                        healthIssuesController.text.trim().isEmpty) {
                      _showErrorDialog(
                          context, 'All fields are required, including Health Issues');
                      return;
                    }

                    _registerUser(
                      context,
                      nameController.text,
                      emailController.text,
                      passwordController.text,
                      healthIssuesController.text,
                    );
                  },
                  child: const Text('Register'),
                ),
              ),
              const SizedBox(height: 16),
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: const Text('Login'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
