import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isDark = authService.isDarkMode;

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          key: ValueKey<bool>(isDark),
          color: isDark ? Colors.amber : Colors.indigo,
        ),
      ),
      onPressed: () {
        authService.toggleThemeMode();
      },
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
} 