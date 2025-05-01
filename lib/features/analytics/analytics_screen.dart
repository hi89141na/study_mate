import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/theme_toggle_button.dart';
import 'mood_chart.dart';
import 'subject_pie_chart.dart';
import 'time_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedTimePeriod = 'all'; // Default to all time
  
  // Get time period dates
  DateTime get _startDate {
    final now = DateTime.now();
    switch (_selectedTimePeriod) {
      case 'today':
        return DateTime(now.year, now.month, now.day);
      case 'week':
        return DateTime(now.year, now.month, now.day - 7);
      case 'month':
        return DateTime(now.year, now.month - 1, now.day);
      case 'year':
        return DateTime(now.year - 1, now.month, now.day);
      default:
        return DateTime(2000); // A date far in the past to include all records
    }
  }
  
  DateTime get _endDate {
    final now = DateTime.now();
    if (_selectedTimePeriod == 'today') {
      return DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
    return now.add(const Duration(days: 1));
  }
  
  String get _timePeriodLabel {
    switch (_selectedTimePeriod) {
      case 'today':
        return 'Today';
      case 'week':
        return 'Past Week';
      case 'month':
        return 'Past Month';
      case 'year':
        return 'Past Year';
      default:
        return 'All Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthService>(context).currentUser?.uid ?? '';
    final firebaseService = Provider.of<FirebaseService>(context);
    
    // If no user is logged in, show a message
    if (userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          actions: [
            const ThemeToggleButton(),
          ],
        ),
        body: const Center(
          child: Text('Please log in to view your analytics'),
        ),
      );
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Your Study Analytics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              _buildTimePeriodDropdown(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Stats for $_timePeriodLabel',
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
            title: 'Study Time',
            child: FutureBuilder<int>(
              future: _selectedTimePeriod == 'all'
                  ? firebaseService.getTotalStudyMinutes(userId)
                  : firebaseService.getStudyMinutesForPeriod(userId, _startDate, _endDate),
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
                    TimeChart(
                      timePeriod: _selectedTimePeriod,
                      startDate: _startDate,
                      endDate: _endDate,
                    ),
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
              future: _selectedTimePeriod == 'all'
                  ? firebaseService.getSubjectDistribution(userId)
                  : firebaseService.getSubjectDistributionForPeriod(userId, _startDate, _endDate),
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
                      child: Text('No data available for this time period'),
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
              future: _selectedTimePeriod == 'all'
                  ? firebaseService.getMoodDistribution(userId)
                  : firebaseService.getMoodDistributionForPeriod(userId, _startDate, _endDate),
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
                      child: Text('No data available for this time period'),
                    ),
                  );
                }
                
                return MoodChart(moodData: moodData);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTimePeriodDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTimePeriod,
          items: [
            DropdownMenuItem(value: 'today', child: Text('Today')),
            DropdownMenuItem(value: 'week', child: Text('Past Week')),
            DropdownMenuItem(value: 'month', child: Text('Past Month')),
            DropdownMenuItem(value: 'year', child: Text('Past Year')),
            DropdownMenuItem(value: 'all', child: Text('All Time')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedTimePeriod = value;
              });
            }
          },
          icon: const Icon(Icons.calendar_today, size: 16),
          elevation: 2,
          isDense: true,
        ),
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
