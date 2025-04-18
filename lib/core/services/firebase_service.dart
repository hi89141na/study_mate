import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../utils/constants.dart';
import '../../models/study_session_model.dart';
import '../../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User related methods
  Future<bool> createUserDocument(UserModel user) async {
    try {
      // Add timeout to prevent hanging
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toMap())
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Firestore operation timed out.');
      });
      print('User document created successfully for uid: ${user.uid}');
      return true;
    } catch (e) {
      print('Error creating user document: $e');
      // Return false instead of rethrowing to avoid crashing the signup process
      // The auth user is still created even if the Firestore document fails
      return false;
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      // Add timeout to prevent hanging
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Firestore operation timed out.');
      });
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null; // Return null on error to prevent app crashes
    }
  }

  Future<void> updateUserThemePreference(String userId, bool isDarkMode) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'isDarkMode': isDarkMode});
  }

  // Study session related methods
  Future<void> saveStudySession(StudySessionModel session) async {
    await _firestore
        .collection(AppConstants.sessionsCollection)
        .doc(session.id)
        .set(session.toMap());
  }

  Stream<List<StudySessionModel>> getStudySessions(String userId) {
    return _firestore
        .collection(AppConstants.sessionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
        .map((doc) => StudySessionModel.fromFirestore(doc))
        .toList();
    });
  }
  
  Future<List<StudySessionModel>> getSessionsByDate(String userId, DateTime date) async {
    // Create DateTime for start and end of the specified date
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));
    
    final snapshot = await _firestore
        .collection(AppConstants.sessionsCollection)
        .where('userId', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThan: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs
        .map((doc) => StudySessionModel.fromFirestore(doc))
        .toList();
  }

  Future<int> getTotalStudyMinutes(String userId) async {
    QuerySnapshot query = await _firestore
        .collection(AppConstants.sessionsCollection)
        .where('userId', isEqualTo: userId)
        .get();
    
    int totalMinutes = 0;
    for (var doc in query.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      totalMinutes += data['durationMinutes'] as int;
    }
    
    return totalMinutes;
  }

  Future<Map<String, int>> getSubjectDistribution(String userId) async {
    QuerySnapshot query = await _firestore
        .collection(AppConstants.sessionsCollection)
        .where('userId', isEqualTo: userId)
        .get();
    
    Map<String, int> subjectDistribution = {};
    for (var doc in query.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String subject = data['subject'];
      int duration = data['durationMinutes'];
      
      if (subjectDistribution.containsKey(subject)) {
        subjectDistribution[subject] = subjectDistribution[subject]! + duration;
      } else {
        subjectDistribution[subject] = duration;
      }
    }
    
    return subjectDistribution;
  }

  Future<Map<int, int>> getMoodDistribution(String userId) async {
    QuerySnapshot query = await _firestore
        .collection(AppConstants.sessionsCollection)
        .where('userId', isEqualTo: userId)
        .get();
    
    Map<int, int> moodDistribution = {};
    for (var doc in query.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      int mood = data['mood'];
      
      if (moodDistribution.containsKey(mood)) {
        moodDistribution[mood] = moodDistribution[mood]! + 1;
      } else {
        moodDistribution[mood] = 1;
      }
    }
    
    return moodDistribution;
  }
} 