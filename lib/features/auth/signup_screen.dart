import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final result = await authService.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
        
        // If we got here and result is not null, registration was successful
        // Navigation is handled by auth state changes
        if (result == null) {
          // This shouldn't happen, but just in case
          setState(() {
            _errorMessage = 'Failed to create account. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = _getFirebaseErrorMessage(e.toString());
        });
        // Print error for debugging
        print('Error during signup: $e');
      }
    }
  }

  String _getFirebaseErrorMessage(String errorCode) {
    if (errorCode.contains('email-already-in-use')) {
      return 'This email is already in use';
    } else if (errorCode.contains('invalid-email')) {
      return 'The email address is not valid';
    } else if (errorCode.contains('operation-not-allowed')) {
      return 'Email/password accounts are not enabled';
    } else if (errorCode.contains('weak-password')) {
      return 'The password is too weak';
    } else if (errorCode.contains('network-request-failed')) {
      return 'Network error. Check your internet connection';
    } else if (errorCode.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later';
    } else if (errorCode.contains('internal-error')) {
      return 'Internal error. Please try again later';
    } else if (errorCode.contains('timed out')) {
      return 'Registration timed out. Please check your connection and try again';
    }
    return 'An error occurred. Please try again';
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InputField(
                  label: 'Name',
                  controller: _nameController,
                  hint: 'Enter your name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputField(
                  label: 'Email',
                  controller: _emailController,
                  hint: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputField(
                  label: 'Password',
                  controller: _passwordController,
                  hint: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _hidePassword,
                  suffixIcon: _hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconPressed: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputField(
                  label: 'Confirm Password',
                  controller: _confirmPasswordController,
                  hint: 'Confirm your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _hideConfirmPassword,
                  suffixIcon: _hideConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixIconPressed: () {
                    setState(() {
                      _hideConfirmPassword = !_hideConfirmPassword;
                    });
                  },
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
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Sign Up',
                  onPressed: _signup,
                  isLoading: authService.isLoading,
                  //width: double.infinity,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black54
                            : Colors.white70,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Login'),
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