import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/theme_toggle_button.dart';
import 'mood_chart.dart';
import 'subject_pie_chart.dart';
import 'time_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firebaseService = Provider.of<FirebaseService>(context);
    
    if (!authService.isAuthenticated) {
      return Center(
        child: Text(
          'You need to login to view analytics',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
    
    final String userId = authService.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      return Center(
        child: Text(
          'Unable to load user data. Please try again.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Study Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your progress and study habits',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black54
                  : Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          _buildAnalyticsCard(
            context,
            title: 'Total Study Time',
            child: FutureBuilder<int>(
              future: firebaseService.getTotalStudyMinutes(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        'Error loading data',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  );
                }
                
                final totalMinutes = snapshot.data ?? 0;
                final hours = totalMinutes ~/ 60;
                final minutes = totalMinutes % 60;
                
                return Column(
                  children: [
                    Text(
                      hours > 0 
                          ? '$hours hrs $minutes min'
                          : '$minutes min',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const TimeChart(),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalyticsCard(
            context,
            title: 'Subject Distribution',
            child: FutureBuilder<Map<String, int>>(
              future: firebaseService.getSubjectDistribution(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        'Error loading data',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  );
                }
                
                final subjectData = snapshot.data;
                
                if (subjectData == null || subjectData.isEmpty) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: Text('No data available'),
                    ),
                  );
                }
                
                return SubjectPieChart(subjectData: subjectData);
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalyticsCard(
            context,
            title: 'Mood Distribution',
            child: FutureBuilder<Map<int, int>>(
              future: firebaseService.getMoodDistribution(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        'Error loading data',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  );
                }
                
                final moodData = snapshot.data;
                
                if (moodData == null || moodData.isEmpty) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: Text('No data available'),
                    ),
                  );
                }
                
                return MoodChart(moodData: moodData);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildAnalyticsCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
