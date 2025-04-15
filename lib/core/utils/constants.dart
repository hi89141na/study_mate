class AppConstants {
  // Collection names
  static const String usersCollection = 'users';
  static const String sessionsCollection = 'study_sessions';
  
  // Shared preferences keys
  static const String isDarkModeKey = 'is_dark_mode';
  static const String userIdKey = 'user_id';
  
  // App info
  static const String appName = 'Study';
  static const String appVersion = '1.0.0';
  
  // Durations
  static const List<int> durationOptions = [15, 30, 45, 60, 90, 120, 180];
  
  // Default values
  static const int defaultDuration = 60; // minutes
  
  // Routes
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String sessionRoute = '/session';
  static const String historyRoute = '/history';
  static const String analyticsRoute = '/analytics';
  static const String calendarRoute = '/calendar';
} 