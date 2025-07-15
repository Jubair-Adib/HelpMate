import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/theme.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.forgotPassword(
        _emailController.text.trim(),
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Reset code sent successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to reset password screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ResetPasswordScreen(email: _emailController.text.trim()),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Icon and Title
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_reset,
                        size: 64,
                        color: const Color(0xFF1565C0),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Reset Your Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                          fontFamily: 'Montserrat',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Description
                const Text(
                  'Enter your email address and we\'ll send you a verification code to reset your password.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Email Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email, color: Color(0xFF1565C0)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      _isLoading
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
                          : const Text(
                            'Send Reset Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                ),

                const SizedBox(height: 24),

                // Back to Login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
