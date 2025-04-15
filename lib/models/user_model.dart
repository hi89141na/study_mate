import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final bool isDarkMode;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.isDarkMode = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isDarkMode: data['isDarkMode'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDarkMode': isDarkMode,
    };
  }

  UserModel copyWith({
    String? displayName,
    bool? isDarkMode,
  }) {
    return UserModel(
      uid: this.uid,
      email: this.email,
      displayName: displayName ?? this.displayName,
      createdAt: this.createdAt,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
} 