class AppConstants {
  // Collection names
  static const String usersCollection = 'users';
  static const String sessionsCollection = 'study_sessions';
  
  // Shared preferences keys
  static const String isDarkModeKey = 'is_dark_mode';
  static const String userIdKey = 'user_id';
  
  // App info
  static const String appName = 'StudyMate';
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
  
  // Mood descriptions
  static const Map<int, String> moodDescriptions = {
    1: 'Great',
    2: 'Good',
    3: 'Neutral',
    4: 'Tired',
    5: 'Stressed',
  };
  
  // Mood emojis
  static const Map<int, String> moodEmojis = {
    1: '😁',
    2: '🙂',
    3: '😐',
    4: '😴',
    5: '😰',
  };
  
  // Motivational quotes
  static const List<String> motivationalQuotes = [
    "The expert in anything was once a beginner.",
    "The beautiful thing about learning is that no one can take it away from you.",
    "Education is the most powerful weapon which you can use to change the world.",
    "The more that you read, the more things you will know. The more that you learn, the more places you'll go.",
    "Learning is never done without errors and defeat.",
    "Education is not the filling of a pail, but the lighting of a fire.",
    "You don't have to be great to start, but you have to start to be great.",
    "The journey of a thousand miles begins with one step.",
    "Do what you can, with what you have, where you are.",
    "Believe you can and you're halfway there."
  ];
} 