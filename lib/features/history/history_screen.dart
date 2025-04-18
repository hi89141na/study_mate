import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../models/study_session_model.dart';
import 'calendar_view.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firebaseService = Provider.of<FirebaseService>(context);
    
    if (!authService.isAuthenticated) {
      return Center(
        child: Text(
          'You need to login to view your history',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    // Get userId safely
    final String userId = authService.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      return Center(
        child: Text(
          'Unable to load user data. Please try again.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Study Sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: const Text('Calendar'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarView(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<StudySessionModel>>(
            stream: firebaseService.getStudySessions(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                );
              }
              
              final sessions = snapshot.data ?? [];
              
              if (sessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_outlined,
                        size: 72,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black12
                            : Colors.white12,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No study sessions yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black54
                              : Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your study history will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black38
                              : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Group sessions by day
              final Map<String, List<StudySessionModel>> groupedSessions = {};
              final dateFormat = DateFormat('MMM d, yyyy');
              
              for (var session in sessions) {
                final date = dateFormat.format(session.createdAt);
                if (!groupedSessions.containsKey(date)) {
                  groupedSessions[date] = [];
                }
                groupedSessions[date]!.add(session);
              }
              
              return ListView.builder(
                itemCount: groupedSessions.length,
                padding: const EdgeInsets.only(bottom: 16),
                itemBuilder: (context, index) {
                  final date = groupedSessions.keys.elementAt(index);
                  final sessionsForDay = groupedSessions[date]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          date,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      ...sessionsForDay.map((session) => _buildSessionCard(context, session)),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildSessionCard(BuildContext context, StudySessionModel session) {
    final timeFormat = DateFormat('h:mm a');
    final timeString = timeFormat.format(session.createdAt);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          session.subject,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${session.durationMinutes} min • $timeString'),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Text(
            session.getMoodEmoji(),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reflection:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.reflection,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black87
                        : Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 