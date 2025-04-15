import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isDarkMode = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  bool get isAuthenticated => _auth.currentUser != null;

  // Constructor initializes the theme
  AuthService() {
    _loadThemePreference();
    _initCurrentUser();
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

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String userId) async {
    UserModel? user = await _firebaseService.getUserData(userId);
    if (user != null) {
      _currentUser = user;
      _isDarkMode = user.isDarkMode;
      await _saveThemePreference(_isDarkMode);
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

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Create the user document in Firestore
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
          isDarkMode: _isDarkMode,
        );

        await _firebaseService.createUserDocument(newUser);
        _currentUser = newUser;
        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      // Don't reset theme preference on logout
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
} 