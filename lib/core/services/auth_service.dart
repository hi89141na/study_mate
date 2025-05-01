import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isDarkMode = false;
  StreamSubscription<User?>? _authStateSubscription;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  bool get isAuthenticated => _auth.currentUser != null;

  // Constructor initializes the theme
  AuthService() {
    _loadThemePreference();
    _initCurrentUser();
    _setupAuthStateListener();
  }

  // Initialize current user if already logged in
  Future<void> _initCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await _fetchUserData(firebaseUser.uid);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Set up a listener for Firebase Auth state changes
  void _setupAuthStateListener() {
    _authStateSubscription = _auth.authStateChanges().listen((User? user) async {
      print('Firebase Auth state changed - User: ${user?.uid}');
      
      if (user != null && (_currentUser == null || _currentUser?.uid != user.uid)) {
        // User logged in or different user logged in
        await _fetchUserData(user.uid);
      } else if (user == null && _currentUser != null) {
        // User logged out
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  // Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(AppConstants.isDarkModeKey) ?? false;
    notifyListeners();
  }

  // Save theme preference to SharedPreferences
  Future<void> _saveThemePreference(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isDarkModeKey, isDarkMode);
  }

  // Toggle theme mode
  Future<void> toggleThemeMode() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemePreference(_isDarkMode);
    
    // If user is logged in, update preference in Firestore
    if (_currentUser != null) {
      await _firebaseService.updateUserThemePreference(
          _currentUser!.uid, _isDarkMode);
      
      // Update local user model
      _currentUser = _currentUser!.copyWith(isDarkMode: _isDarkMode);
    }
    
    notifyListeners();
  }

  // Add a method to manually refresh user data
  Future<bool> refreshUserData() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        await _fetchUserData(firebaseUser.uid);
        return true;
      } catch (e) {
        print('Error refreshing user data: $e');
        return false;
      }
    }
    return false;
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String userId) async {
    try {
      print('Fetching user data for $userId');
      UserModel? user = await _firebaseService.getUserData(userId);
      
      if (user != null) {
        print('User data fetched successfully: ${user.displayName}');
        _currentUser = user;
        _isDarkMode = user.isDarkMode;
        await _saveThemePreference(_isDarkMode);
        notifyListeners(); // Notify listeners after updating the user data
      } else {
        print('No user data found in Firestore for $userId');
        // Create a default user if Firebase Auth has the user but Firestore doesn't
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          final defaultUser = UserModel(
            uid: userId,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? 'User',
            createdAt: DateTime.now(),
            isDarkMode: _isDarkMode,
          );
          
          // Try to save this default user to Firestore
          await _firebaseService.createUserDocument(defaultUser);
          _currentUser = defaultUser;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error in _fetchUserData: $e');
      // Don't throw, just log the error
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        await _fetchUserData(user.uid);
        return _currentUser;
      }
      return null;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Add timeout to prevent infinite loading
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Registration timed out. Please check your connection.');
      });

      User? user = result.user;
      if (user != null) {
        try {
          // Create the user document in Firestore
          UserModel newUser = UserModel(
            uid: user.uid,
            email: email,
            displayName: displayName,
            createdAt: DateTime.now(),
            isDarkMode: _isDarkMode,
          );

          bool firestoreSuccess = await _firebaseService.createUserDocument(newUser);
          if (!firestoreSuccess) {
            print('Warning: User created in Authentication but Firestore document creation failed');
          }
          
          // Set current user regardless of Firestore result
          _currentUser = newUser;
          return newUser;
        } catch (e) {
          // If Firestore document creation fails but Firebase Auth succeeded
          print('User created in Authentication but failed in Firestore: $e');
          // Still return a user to avoid showing an error
          _currentUser = UserModel(
            uid: user.uid, 
            email: email,
            displayName: displayName,
            createdAt: DateTime.now(),
            isDarkMode: _isDarkMode,
          );
          return _currentUser;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Log the detailed error for debugging
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow; // Rethrow to be handled by the UI
    } catch (e) {
      // Log general errors
      print('Error during registration: $e');
      rethrow;
    } finally {
      // Ensure loading state is reset
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in process
        return null;
      }

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google Auth credential
      final UserCredential result = await _auth.signInWithCredential(credential);
      final User? user = result.user;

      if (user != null) {
        // Check if the user exists in Firestore
        UserModel? existingUser = await _firebaseService.getUserData(user.uid);

        if (existingUser == null) {
          // User doesn't exist in Firestore, create a new document
          UserModel newUser = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? 'Google User',
            createdAt: DateTime.now(),
            isDarkMode: _isDarkMode,
          );

          await _firebaseService.createUserDocument(newUser);
          _currentUser = newUser;
        } else {
          // User already exists in Firestore
          _currentUser = existingUser;
          _isDarkMode = existingUser.isDarkMode;
          await _saveThemePreference(_isDarkMode);
        }

        notifyListeners();
        return _currentUser;
      }
      
      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentUser = null;
      // Don't reset theme preference on logout
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
} 