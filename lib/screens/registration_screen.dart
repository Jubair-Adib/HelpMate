import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import '../models/category.dart'; // Added import for Category model
import '../services/api_service.dart'; // Added import for ApiService

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _skillsController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _lookingForWork = false;

  // Category state
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isCategoryLoading = false;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    // Optionally, fetch categories here if you want them preloaded
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isCategoryLoading = true;
      _categoryError = null;
    });
    try {
      final categoriesData = await ApiService().getCategories();
      final categories =
          categoriesData
              .map<Category>((json) => Category.fromJson(json))
              .toList();
      setState(() {
        _categories = categories;
        _isCategoryLoading = false;
      });
    } catch (e) {
      setState(() {
        _categoryError = 'Failed to load categories';
        _isCategoryLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _skillsController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lookingForWork && _selectedCategory == null) {
      setState(() {
        _categoryError = 'Please select a category';
      });
      return;
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    if (_lookingForWork) {
      // Pass categoryId if your backend supports it
      success = await authProvider.registerWorker(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        skills:
            _skillsController.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
        hourlyRate: double.parse(_hourlyRateController.text),
        lookingForWork: _lookingForWork,
        categoryId: _selectedCategory!.id,
      );
    } else {
      success = await authProvider.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Registration failed'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Looking for work checkbox
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: CheckboxListTile(
                      title: Text(
                        'I am looking for work',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Check this if you want to offer services',
                        style: AppTheme.bodySmall,
                      ),
                      value: _lookingForWork,
                      onChanged: (value) async {
                        setState(() {
                          _lookingForWork = value!;
                          _selectedCategory = null;
                          _categoryError = null;
                        });
                        if (value == true && _categories.isEmpty) {
                          await _fetchCategories();
                        }
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppTheme.primaryColor,
                    ),
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

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
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

                const SizedBox(height: AppTheme.spacingL),

                // Worker-specific fields
                if (_lookingForWork) ...[
                  Text('Professional Information', style: AppTheme.heading4),
                  const SizedBox(height: AppTheme.spacingM),

                  // Category Dropdown
                  _isCategoryLoading
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        items:
                            _categories
                                .map(
                                  (cat) => DropdownMenuItem<Category>(
                                    value: cat,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.category,
                                          color: AppTheme.primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(cat.name),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (cat) {
                          setState(() {
                            _selectedCategory = cat;
                            _categoryError = null;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Category',
                          prefixIcon: const Icon(Icons.category),
                          errorText: _categoryError,
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                  const SizedBox(height: AppTheme.spacingL),

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
                ],

                // Password
                Text('Security', style: AppTheme.heading4),
                const SizedBox(height: AppTheme.spacingM),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.spacingXL),

                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _register,
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
                              : Text(
                                _lookingForWork
                                    ? 'Register as Service Provider'
                                    : 'Create Account',
                              ),
                    );
                  },
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
