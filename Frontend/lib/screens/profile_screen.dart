import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../app_routes.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _healthIssuesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await LocalStorageService.getCurrentUser();
    setState(() {
      _user = user;
      if (user != null) {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _healthIssuesController.text = user['healthIssues'] ?? '';
      }
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    final success = await LocalStorageService.updateUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      healthIssues: _healthIssuesController.text.trim(),
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        setState(() {
          _isEditing = false;
        });
        _loadUserData();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await LocalStorageService.logoutUser();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: MyApp.sageGreenLight,
        body: const Center(
          child: CircularProgressIndicator(color: MyApp.sageGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: MyApp.sageGreenLight,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: MyApp.sageGreen,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Profile Avatar
              CircleAvatar(
                radius: 60,
                backgroundColor: MyApp.sageGreen,
                child: Text(
                  _user?['name']?.toString().isNotEmpty == true 
                      ? _user!['name'][0].toUpperCase() 
                      : 'U',
                  style: const TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Name Field
              _buildProfileField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.person,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),

              // Email Field
              _buildProfileField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),

              // Health Issues Field
              _buildProfileField(
                controller: _healthIssuesController,
                label: 'Health Issues',
                icon: Icons.health_and_safety,
                enabled: _isEditing,
              ),
              const SizedBox(height: 30),

              // Action Buttons
              if (_isEditing) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyApp.sageGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _loadUserData();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: MyApp.sageGreen),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: MyApp.sageGreen),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: MyApp.sageGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: MyApp.sageGreen.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MyApp.sageGreen, width: 2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _healthIssuesController.dispose();
    super.dispose();
  }
}

