import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

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

  bool _lookingForWork = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone);
    _addressController = TextEditingController(text: widget.user.address);

    if (widget.user is Worker) {
      final worker = widget.user as Worker;
      _skillsController = TextEditingController(text: worker.skills);
      _hourlyRateController = TextEditingController(
        text: worker.hourlyRate.toString(),
      );
      _lookingForWork = worker.lookingForWork;
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final updateData = <String, dynamic>{
      'full_name': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };

    if (widget.user is Worker) {
      updateData['skills'] = _skillsController.text.trim();
      updateData['hourly_rate'] = double.parse(_hourlyRateController.text);
      updateData['looking_for_work'] = _lookingForWork;
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

                // Looking for work checkbox
                CheckboxListTile(
                  title: const Text('Looking for work'),
                  value: _lookingForWork,
                  onChanged: (value) {
                    setState(() {
                      _lookingForWork = value!;
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
