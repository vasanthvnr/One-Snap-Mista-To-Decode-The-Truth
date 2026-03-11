import 'package:flutter/material.dart';
import '../app_routes.dart';
import '../services/local_storage_service.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  // Unique quotes for the health care app
  final List<String> _quotes = [
    "Your Health, Our Priority",
    "Scan Smart, Live Healthy",
    "Know What You Consume",
    "Healthy Choices Start Here",
    "Ingredient Analysis Made Simple",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await LocalStorageService.getCurrentUser();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  void _navigateToCategory(BuildContext context, String category) {
    if (_user == null) {
      // Not logged in, redirect to login
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }
    Navigator.pushNamed(context, AppRoutes.camera, arguments: {
      'category': category,
      'healthIssues': _user?['healthIssues'] ?? '',
    });
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color, VoidCallback onTap, BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: 160,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              radius: 40,
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _getRandomQuote() {
    final index = DateTime.now().millisecondsSinceEpoch % _quotes.length;
    return _quotes[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.sageGreenLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Logo (left), Title (center), Login/Profile (right)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo at top left
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset('assets/LOGO.png', width: 32, height: 32),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Health Care',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: MyApp.sageGreenDark,
                        ),
                      ),
                    ],
                  ),
                  // Login button or Profile icon at top right
                  _isLoading
                      ? const SizedBox()
                      : _user != null
                          ? GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                              child: CircleAvatar(
                                backgroundColor: MyApp.sageGreen,
                                radius: 20,
                                child: Text(
                                  _user!['name']?.toString().isNotEmpty == true
                                      ? _user!['name'][0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyApp.sageGreen,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('Login'),
                            ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Center Quote instead of icon
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: MyApp.sageGreen.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        '"${_getRandomQuote()}"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: MyApp.sageGreenDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Category Cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCategoryCard('Skincare', Icons.spa, MyApp.sageGreen, () => _navigateToCategory(context, 'skincare'), context),
                        _buildCategoryCard('Food', Icons.fastfood, MyApp.sageGreenDark, () => _navigateToCategory(context, 'food'), context),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Info Container
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: MyApp.sageGreen.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Select a category and scan product ingredients to get health analysis',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14, 
                          color: MyApp.sageGreenDark,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
