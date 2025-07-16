import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/auth_provider.dart';
import '../models/worker.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final Object user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _skillsController;
  late TextEditingController _hourlyRateController;

  bool _isAvailable = false;
  String? _imagePath;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: (widget.user as dynamic).fullName,
    );
    _phoneController = TextEditingController(
      text:
          (widget.user as dynamic).phone ??
          (widget.user as dynamic).phoneNumber ??
          '',
    );
    _addressController = TextEditingController(
      text: (widget.user as dynamic).address ?? '',
    );
    // Use image field if present, else null
    _imagePath = (widget.user as dynamic).image;
    if (widget.user is Worker) {
      final worker = widget.user as Worker;
      _skillsController = TextEditingController(
        text: worker.skills != null ? worker.skills!.join(', ') : '',
      );
      _hourlyRateController = TextEditingController(
        text: worker.hourlyRate?.toString() ?? '',
      );
      _isAvailable = worker.isAvailable;
    } else {
      _skillsController = TextEditingController();
      _hourlyRateController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _skillsController.dispose();
    _hourlyRateController.dispose();
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final updateData = <String, dynamic>{
      'full_name': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };

    if (_imagePath != null) {
      updateData['image'] = _imagePath;
    }

    if (widget.user is Worker) {
      final skillsList =
          _skillsController.text
              .trim()
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
      updateData['skills'] = skillsList;
      if (_hourlyRateController.text.isNotEmpty) {
        updateData['hourly_rate'] = double.parse(_hourlyRateController.text);
      }
      updateData['is_available'] = _isAvailable;
    }

    final success = await authProvider.updateProfile(updateData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to update profile'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        actions: [
          TextButton(onPressed: _saveProfile, child: const Text('Save')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      backgroundImage:
                          _imageFile != null
                              ? FileImage(_imageFile!)
                              : (_imagePath != null && _imagePath!.isNotEmpty)
                              ? NetworkImage(_imagePath!) as ImageProvider
                              : null,
                      child:
                          (_imageFile == null &&
                                  (_imagePath == null || _imagePath!.isEmpty))
                              ? const Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.grey,
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
              const SizedBox(height: AppTheme.spacingL),
              // Basic Information
              Text('Basic Information', style: AppTheme.heading4),
              const SizedBox(height: AppTheme.spacingM),

              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Address
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),

              // Worker-specific fields
              if (widget.user is Worker) ...[
                const SizedBox(height: AppTheme.spacingXL),

                Text('Professional Information', style: AppTheme.heading4),
                const SizedBox(height: AppTheme.spacingM),

                // Skills
                TextFormField(
                  controller: _skillsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Skills & Services',
                    prefixIcon: Icon(Icons.work_outlined),
                    hintText: 'e.g., Plumbing, Electrical, Cleaning, etc.',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your skills';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Hourly Rate
                TextFormField(
                  controller: _hourlyRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Hourly Rate (\$)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your hourly rate';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Available for work checkbox
                CheckboxListTile(
                  title: const Text('Available for work'),
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],

              const SizedBox(height: AppTheme.spacingXL),

              // Save Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _saveProfile,
                    child:
                        authProvider.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.surfaceColor,
                                ),
                              ),
                            )
                            : const Text('Save Changes'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
