import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
import '../../models/study_session_model.dart';
import 'package:intl/intl.dart';

class TimeChart extends StatefulWidget {
  const TimeChart({Key? key}) : super(key: key);

  @override
  State<TimeChart> createState() => _TimeChartState();
}

class _TimeChartState extends State<TimeChart> {
  bool _isLoading = true;
  List<StudySessionModel> _sessions = [];
  Map<String, double> _dailyMinutes = {};
  String? _errorMessage;
  StreamSubscription<List<StudySessionModel>>? _sessionsSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _sessionsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      if (authService.currentUser != null) {
        final userId = authService.currentUser!.uid;
        // Subscribe to the stream
        _sessionsSubscription = firebaseService.getStudySessions(userId).listen(
          (sessions) {
            // Process data for chart
            final Map<String, double> dailyMinutes = {};
            
            // Get the last 7 days
            final DateTime now = DateTime.now();
            for (int i = 6; i >= 0; i--) {
              final date = DateTime(now.year, now.month, now.day - i);
              final dateString = DateFormat('MMM d').format(date);
              dailyMinutes[dateString] = 0;
            }
            
            // Add session durations to the appropriate day
            for (var session in sessions) {
              final sessionDate = DateTime(
                session.createdAt.year,
                session.createdAt.month,
                session.createdAt.day,
              );
              
              // Only include sessions from the last 7 days
              final daysDifference = now.difference(sessionDate).inDays;
              if (daysDifference <= 6) {
                final dateString = DateFormat('MMM d').format(sessionDate);
                dailyMinutes[dateString] = (dailyMinutes[dateString] ?? 0) + session.durationMinutes;
              }
            }
            
            setState(() {
              _sessions = sessions;
              _dailyMinutes = dailyMinutes;
              _isLoading = false;
            });
          },
          onError: (error) {
            setState(() {
              _errorMessage = 'Error loading data: ${error.toString()}';
              _isLoading = false;
            });
          },
        );
      } else {
        setState(() {
          _errorMessage = 'You must be logged in to view analytics';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bar_chart,
              color: Colors.grey,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Data Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking study sessions to see your progress',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black54
                    : Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = _dailyMinutes.keys.elementAt(groupIndex);
                final minutes = _dailyMinutes[date]!.toInt();
                return BarTooltipItem(
                  '$date\n$minutes min',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= _dailyMinutes.length) {
                    return const SizedBox.shrink();
                  }
                  final date = _dailyMinutes.keys.elementAt(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '${value.toInt()} min',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            horizontalInterval: _getInterval(),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          barGroups: _buildBarGroups(),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return _dailyMinutes.entries.map((entry) {
      final index = _dailyMinutes.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            width: 20,
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY() {
    if (_dailyMinutes.isEmpty) return 60; // Default
    
    final maxValue = _dailyMinutes.values.reduce((a, b) => a > b ? a : b);
    // Round up to nearest multiple of the interval for neat chart
    final interval = _getInterval();
    return ((maxValue / interval).ceil() * interval) + interval;
  }

  double _getInterval() {
    if (_dailyMinutes.isEmpty) return 30; // Default
    
    final maxValue = _dailyMinutes.values.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 60) return 15;
    if (maxValue <= 120) return 30;
    if (maxValue <= 240) return 60;
    return 120;
  }
} 