# StudyMate Technical Documentation

## 1. App Summary

StudyMate is a Flutter application designed to help students track and analyze their study sessions. The app allows users to log study sessions with details like subject, duration, mood, and reflections. Users can view their study history through a calendar view, track analytics about their study habits, and receive motivational quotes. The app features user authentication, data persistence using Firebase, and a theme toggle between light and dark modes.

*Main Features:*
- User authentication (signup/login)
- Study session logging with subject, duration, mood, and reflection
- Session history with calendar view
- Study analytics with visual charts (time, mood, subject distribution)
- Light/dark theme toggle
- Motivational quotes

## 2. Project Structure


lib/
├── core/
│   ├── services/      # Core services for authentication and Firebase
│   ├── theme/         # App theming
│   └── utils/         # Constants and utilities
├── features/
│   ├── analytics/     # Analytics screen and charts
│   ├── auth/          # Authentication screens and controllers
│   ├── history/       # History screen and calendar view
│   ├── home/          # Home screen and welcome widget
│   └── session/       # Session logging functionality
├── models/            # Data models
├── widgets/           # Reusable widgets
└── main.dart          # App entry point


### Key Files Breakdown:

#### Core
- core/services/auth_service.dart: Manages Firebase authentication and user state
- core/services/firebase_service.dart: Handles Firestore database operations
- core/theme/app_theme.dart: Defines light and dark themes
- core/utils/constants.dart: App-wide constants
- core/utils/enums.dart: Enumerations like MoodType

#### Features
- features/analytics/: Charts for study data visualization
- features/auth/: Login, signup, and authentication control
- features/history/: Session history and calendar view
- features/home/: Main screen and welcome dashboard
- features/session/: Session creation and form

#### Models
- models/user_model.dart: User data structure
- models/study_session_model.dart: Study session data structure

#### Widgets
- widgets/custom_button.dart: Standardized button component
- widgets/input_field.dart: Text input component
- widgets/mood_selector.dart: Mood selection component
- widgets/quote_banner.dart: Motivational quote display

## 3. Libraries and Packages

From the code imports, the following packages are used:

1. *Firebase Core* - Base Firebase functionality
2. *Firebase Auth* - For user authentication
3. *Cloud Firestore* - NoSQL database for storing user and session data
4. *Provider* - State management solution
5. *Intl* - For date formatting and internationalization
6. *Shared Preferences* - Local storage for theme settings
7. *FL Chart* - For creating analytics charts (bar, pie)
8. *Table Calendar* - For the calendar view in history
9. *UUID* - For generating unique IDs for study sessions

## 4. Program Flow

### Startup Flow:
1. main.dart initializes Firebase and sets up the app
2. The app checks for an existing user session (via AuthService)
3. Based on authentication state, either:
   - Shows login/signup screen (if not authenticated)
   - Shows home screen (if authenticated)

### Navigation Flow:
- The app uses a bottom navigation bar for main navigation between:
  - Home
  - New Session
  - History
  - Analytics
- Direct navigation is also provided via named routes

### Data Flow:
1. User creates a study session via the form
2. Data is saved to Firebase Firestore
3. History and analytics screens fetch and display the data
4. Real-time updates are handled via Firestore streams

## 5. Screens and Pages

### Authentication Screens
- *LoginScreen*: Email/password login form
- *SignupScreen*: Registration form with email, password, and name
- *AuthController*: Manages authentication state and routing

### Home Screen
- *HomeScreen*: Main navigation with bottom navbar
- *WelcomeWidget*: Greeting based on time of day, user stats, and quick action card

### Session Screens
- *StartSessionScreen*: Form to log a new study session
- *SessionFormWidget*: Input form with subject, duration, mood, and reflection

### History Screens
- *HistoryScreen*: List of study sessions grouped by date
- *CalendarView*: Calendar visualization of study sessions

### Analytics Screens
- *AnalyticsScreen*: Overall analytics dashboard
- *TimeChart*: Bar chart of study durations
- *SubjectPieChart*: Pie chart of study subjects
- *MoodChart*: Distribution of mood during study sessions

## 6. Models, Services, and Utilities

### Models
- *UserModel*: Represents user data (uid, email, displayName, createdAt, isDarkMode)
- *StudySessionModel*: Represents study session data (id, userId, subject, durationMinutes, mood, reflection, createdAt)

### Services
- *AuthService*: Manages Firebase authentication, user state, and theme preferences
- *FirebaseService*: Handles Firestore operations for study sessions and user data

### Utilities
- *AppConstants*: Constants for collections, routes, mood descriptions/emojis, motivational quotes
- *AppTheme*: Light and dark theme definitions
- *Enums*: Type definitions like MoodType

## 7. Data Handling and Storage

### Firebase Firestore
- *Collections*:
  - users: Stores user profiles
  - study_sessions: Stores study session data
- *Operations*:
  - CRUD operations for users and sessions
  - Queries for analytics (getTotalStudyMinutes, getSubjectDistribution, getMoodDistribution)
  - Date-based filtering for calendar view

### Local Storage
- *SharedPreferences*: Used to store theme preference (dark/light mode)

### UI Integration
- *StreamBuilder*: Used for real-time data in HistoryScreen
- *FutureBuilder*: Used for async data in analytics charts

## 8. Authentication Implementation

- *Firebase Authentication*: Email and password authentication
- *User Session*: 
  - Managed through AuthService
  - Persistence handled by Firebase Auth
  - User state listened to via authStateChanges() stream
- *User Profile*:
  - Created in Firestore upon signup
  - Contains display name and theme preference
- *Session Management*:
  - Auth state checked at app startup
  - Token refreshing handled by Firebase
- *Logout*: Clears Firebase Auth state but preserves theme preference

## 9. Theme and Styling

- *ThemeData*: Defined in AppTheme class
- *Light/Dark Modes*:
  - Toggle via ThemeToggleButton
  - Preference stored in SharedPreferences and Firestore
  - Applied via MaterialApp's theme and darkTheme properties
- *Consistent Styling*:
  - Card/input styling consistent throughout the app
  - Material 3 design elements
  - Responsive sizing with proper constraints

## 10. Navigation

- *Navigator 1.0*: Traditional navigation with named routes
- *Bottom Navigation*: For main app sections (home, session, history, analytics)
- *Routes*: Defined in MaterialApp's routes property
- *Route Constants*: Defined in AppConstants

## 11. State Management

- *Provider*: Used for app-wide state management
- *ChangeNotifier*: AuthService extends ChangeNotifier to broadcast changes
- *Consumer*: Used to rebuild UI when authentication state changes
- *LocalState*: StatefulWidget's setState for local UI state

## 12. Error Handling and Validation

- *Form Validation*: Input validation in forms with FormField validators
- *Error Handling*:
  - try/catch blocks for Firebase operations
  - Error messaging via SnackBar
  - FutureBuilder and StreamBuilder error states
- *Null Safety*: Implemented throughout with proper null checks
- *Safe Navigation*: Guards against navigation when context is invalid

## 13. Performance Optimizations

- *Lazy Loading*: Data loaded only when needed
- *Firestore Queries*: Optimized to fetch only necessary data
- *Widget Optimization*:
  - const constructors where possible
  - Disposal of controllers and streams
- *Mounted Checks*: Prevents setState after widget disposal

## 14. Potential Improvements

1. *Offline Support*: Implement Firestore offline persistence for better offline experience
2. *Testing*: Add unit and widget tests
3. *Accessibility*: Improve for screen readers and keyboard navigation
4. *Notifications*: Add study reminders
5. *Localization*: Add multiple language support
6. *Better Error Reporting*: More detailed error messages and logging
7. *Social Features*: Share study achievements
8. *Data Export*: Allow exporting study data
9. *Enhanced Analytics*: More charts and insights
10. *Push Notifications*: For study reminders and streak maintenance

This application follows a feature-first architecture with clear separation of concerns between UI, business logic, and data layers. It makes good use of Firebase services for authentication and data storage while maintaining a clean and consistent UI with proper theming support.



How to get sha values use
keytool -list -v -keystore "C:\Users\User\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android