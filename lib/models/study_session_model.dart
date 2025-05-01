import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class StudySessionModel {
  final String id;
  final String userId;
  final String subject;
  final int durationMinutes;
  final int mood; // 1-5 scale: 1=great, 2=good, 3=neutral, 4=tired, 5=stressed
  final String reflection;
  final DateTime createdAt;

  StudySessionModel({
    String? id,
    required this.userId,
    required this.subject,
    required this.durationMinutes,
    required this.mood,
    required this.reflection,
    DateTime? createdAt,
  }) : 
    this.id = id ??  Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now();

  factory StudySessionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StudySessionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      subject: data['subject'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      mood: data['mood'] ?? 3,
      reflection: data['reflection'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'subject': subject,
      'durationMinutes': durationMinutes,
      'mood': mood,
      'reflection': reflection,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String getMoodEmoji() {
    switch (mood) {
      case 1: return '😁'; // Great
      case 2: return '🙂'; // Good
      case 3: return '😐'; // Neutral
      case 4: return '😴'; // Tired
      case 5: return '😰'; // Stressed
      default: return '😐';
    }
  }

  String getMoodString() {
    switch (mood) {
      case 1: return 'Great';
      case 2: return 'Good';
      case 3: return 'Neutral';
      case 4: return 'Tired';
      case 5: return 'Stressed';
      default: return 'Neutral';
    }
  }
} 