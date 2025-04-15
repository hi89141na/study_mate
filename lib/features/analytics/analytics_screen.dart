import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import 'mood_chart.dart';
import 'subject_pie_chart.dart';
import 'time_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: isDarkMode ? Colors.white : Colors.black,
          tabs: const [
            Tab(text: 'Time'),
            Tab(text: 'Mood'),
            Tab(text: 'Subjects'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContent(
            title: 'Study Time',
            description: 'Track your study hours over time',
            chart: const TimeChart(),
          ),
          _buildContent(
            title: 'Mood Trends',
            description: 'See how your mood changes during study sessions',
            chart: const MoodChart(sessions: []),
          ),
          _buildContent(
            title: 'Subject Distribution',
            description: 'Analyze time spent on different subjects',
            chart: const SubjectPieChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent({
    required String title,
    required String description,
    required Widget chart,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black54
                  : Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(child: chart),
        ],
      ),
    );
  }
} 