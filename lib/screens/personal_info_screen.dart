import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/worker.dart' as worker_models;
import 'package:image_picker/image_picker.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _imagePath;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _imagePath = picked.path;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      final userType = authProvider.userType;

      Map<String, dynamic> userProfile;
      if (userType == 'worker' && currentUser is worker_models.Worker) {
        userProfile = await _apiService.getWorkerProfile();
      } else {
        userProfile = await _apiService.getUserProfile();
      }

      setState(() {
        _nameController.text = userProfile['full_name'] ?? '';
        _emailController.text = userProfile['email'] ?? '';
        // Use 'phone_number' instead of 'phone'
        _phoneController.text = userProfile['phone_number'] ?? '';
        _addressController.text = userProfile['address'] ?? '';
        _imagePath = userProfile['image'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isSaving = true;
        _error = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userType = authProvider.userType;

      String? imageUrl;
      // If a new image is picked and not already a URL, upload it
      if (_imageFile != null &&
          (_imagePath == null || !_imagePath!.startsWith('http'))) {
        if (userType == 'worker') {
          imageUrl = await _apiService.uploadWorkerProfileImage(_imageFile!);
        } else {
          imageUrl = await _apiService.uploadUserProfileImage(_imageFile!);
        }
      }

      final profileData = {
        'full_name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        if (imageUrl != null) 'image': imageUrl,
        if (imageUrl == null && _imagePath != null) 'image': _imagePath,
      };

      if (userType == 'worker') {
        await _apiService.updateWorkerProfile(profileData);
      } else {
        await _apiService.updateUserProfile(profileData);
      }

      // Update the auth provider with new user data
      await authProvider.refreshUserProfile();

      // Reload profile to update UI with new image/phone
      await _loadUserProfile();

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text('Error loading profile', style: AppTheme.heading4),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      _error!,
                      style: AppTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    ElevatedButton(
                      onPressed: _loadUserProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Picture Section
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppTheme.primaryColor
                                  .withOpacity(0.1),
                              backgroundImage:
                                  _imageFile != null
                                      ? FileImage(_imageFile!)
                                      : (_imagePath != null &&
                                          _imagePath!.isNotEmpty)
                                      ? NetworkImage(_imagePath!)
                                          as ImageProvider
                                      : null,
                              child:
                                  (_imageFile == null &&
                                          (_imagePath == null ||
                                              _imagePath!.isEmpty))
                                      ? Text(
                                        _nameController.text.isNotEmpty
                                            ? _nameController.text
                                                .split(' ')
                                                .map((e) => e[0])
                                                .join('')
                                            : 'U',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      )
                                      : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXL),

                      // Form Fields
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingM),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        enabled: false, // Email cannot be changed
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: AppTheme.spacingM),

                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter your phone number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingM),

                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          hintText: 'Enter your address',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingXL),

                      // Save Button
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingM,
                          ),
                        ),
                        child:
                            _isSaving
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
