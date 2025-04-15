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

    if (authService.isAuthenticated) {
      return homeScreenBuilder;
    }

    return authScreenBuilder;
  }
} 