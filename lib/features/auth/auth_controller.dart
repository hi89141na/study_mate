import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class AuthController extends StatelessWidget {
  final Widget authScreenBuilder;
  final Widget homeScreenBuilder;
  final Widget? loadingScreen;

  const AuthController({
    Key? key,
    required this.authScreenBuilder,
    required this.homeScreenBuilder,
    this.loadingScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Print debug information
    print('AuthController - isLoading: ${authService.isLoading}');
    print('AuthController - isAuthenticated: ${authService.isAuthenticated}');
    print('AuthController - currentUser: ${authService.currentUser}');

    if (authService.isLoading) {
      return loadingScreen ??
          Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
    }

    // Check both Firebase Auth state and our own user model
    if (authService.isAuthenticated || authService.currentUser != null) {
      return homeScreenBuilder;
    }

    return authScreenBuilder;
  }
} 