import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum MoodType { great, good, neutral, tired, stressed }

class StudySessionModel {
  final String id;
  final String userId;
  final String subject;
  final int durationMinutes;
  final MoodType mood;
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
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now();

  factory StudySessionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StudySessionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      subject: data['subject'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      mood: MoodType.values[data['mood'] ?? 2], // Default to neutral
      reflection: data['reflection'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'subject': subject,
      'durationMinutes': durationMinutes,
      'mood': mood.index,
      'reflection': reflection,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String getMoodEmoji() {
    switch (mood) {
      case MoodType.great:
        return '😁';
      case MoodType.good:
        return '🙂';
      case MoodType.neutral:
        return '😐';
      case MoodType.tired:
        return '😴';
      case MoodType.stressed:
        return '😰';
      default:
        return '😐';
    }
  }

  String getMoodString() {
    switch (mood) {
      case MoodType.great:
        return 'Great';
      case MoodType.good:
        return 'Good';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.tired:
        return 'Tired';
      case MoodType.stressed:
        return 'Stressed';
      default:
        return 'Neutral';
    }
  }
} 