import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
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
import 'package:study/firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        // Show loading screen or error message during Firebase initialization
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Initializing app...'),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'Failed to initialize Firebase: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => runApp(const MyApp()),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        
        // Firebase initialized successfully, build the actual app
        return MultiProvider(
          providers: [
            Provider<FirebaseService>(
              create: (_) => FirebaseService(),
            ),
            ChangeNotifierProvider<AuthService>(
              create: (context) {
                // Create auth service
                final authService = AuthService();
                
                // Debug prints
                print('Initial Auth State: isAuthenticated=${authService.isAuthenticated}');
                print('Initial Auth State: currentUser=${authService.currentUser}');
                
                // Listen for auth changes
                authService.addListener(() {
                  print('Auth State Changed: isAuthenticated=${authService.isAuthenticated}');
                  print('Auth State Changed: currentUser=${authService.currentUser}');
                });
                
                return authService;
              },
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
      },
    );
  }
  
  Future<FirebaseApp> _initializeFirebase() async {
    // Add a timeout to Firebase initialization to avoid hanging
    try {
      return await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Firebase initialization timed out. Check your internet connection.');
      });
    } catch (e) {
      print('Firebase initialization error: $e');
      rethrow;
    }
  }
}
