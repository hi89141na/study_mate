import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/core/services/auth_service.dart';
import 'package:study/core/services/firebase_service.dart';
import 'package:study/core/theme/app_theme.dart';
import 'package:study/core/utils/constants.dart';
import 'package:study/features/analytics/analytics_screen.dart';
import 'package:study/features/auth/auth_controller.dart';
import 'package:study/features/auth/login_screen.dart';
import 'package:study/features/auth/signup_screen.dart';
import 'package:study/features/history/calendar_view.dart';
import 'package:study/features/history/history_screen.dart';
import 'package:study/features/home/home_screen.dart';
import 'package:study/features/session/start_session_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseService>(
          create: (_) => FirebaseService(),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: authService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthController(
              authScreenBuilder: LoginScreen(),
              homeScreenBuilder: HomeScreen(),
            ),
            routes: {
              AppConstants.loginRoute: (context) => const LoginScreen(),
              AppConstants.signupRoute: (context) => const SignupScreen(),
              AppConstants.homeRoute: (context) => const HomeScreen(),
              AppConstants.sessionRoute: (context) => const StartSessionScreen(),
              AppConstants.historyRoute: (context) => const HistoryScreen(),
              AppConstants.analyticsRoute: (context) => const AnalyticsScreen(),
              AppConstants.calendarRoute: (context) => const CalendarView(),
            },
          );
        },
      ),
    );
  }
}
