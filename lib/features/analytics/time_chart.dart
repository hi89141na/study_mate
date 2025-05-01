import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
import '../../models/study_session_model.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class TimeChart extends StatefulWidget {
  final String? timePeriod;
  final DateTime? startDate;
  final DateTime? endDate;
  
  const TimeChart({
    Key? key, 
    this.timePeriod,
    this.startDate,
    this.endDate,
  }) : super(key: key);

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
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      if (authService.isAuthenticated) {
        final userId = authService.currentUser?.uid ?? '';
        if (userId.isEmpty) {
          setState(() {
            _errorMessage = 'Unable to load user data. Please try again.';
            _isLoading = false;
          });
          return;
        }
        
        // Subscribe to the stream
        _sessionsSubscription = firebaseService.getStudySessions(userId).listen(
          (sessions) {
            if (!mounted) return;
            
            // Filter sessions based on time period if specified
            final DateTime now = DateTime.now();
            DateTime startFilterDate;
            
            if (widget.startDate != null) {
              startFilterDate = widget.startDate!;
            } else if (widget.timePeriod != null) {
              switch (widget.timePeriod) {
                case 'today':
                  startFilterDate = DateTime(now.year, now.month, now.day);
                  break;
                case 'week':
                  startFilterDate = DateTime(now.year, now.month, now.day - 6);
                  break;
                case 'month':
                  startFilterDate = DateTime(now.year, now.month - 1, now.day);
                  break;
                case 'year':
                  startFilterDate = DateTime(now.year - 1, now.month, now.day);
                  break;
                default:
                  // Default to last 7 days if no period specified
                  startFilterDate = DateTime(now.year, now.month, now.day - 6);
              }
            } else {
              // Default to last 7 days if no period specified
              startFilterDate = DateTime(now.year, now.month, now.day - 6);
            }
            
            DateTime endFilterDate = widget.endDate ?? DateTime(now.year, now.month, now.day + 1);
            
            // Filter sessions by date range
            final filteredSessions = sessions.where((session) {
              final sessionDate = DateTime(
                session.createdAt.year,
                session.createdAt.month,
                session.createdAt.day,
              );
              return sessionDate.isAfter(startFilterDate.subtract(const Duration(days: 1))) && 
                     sessionDate.isBefore(endFilterDate);
            }).toList();
            
            // Process data for chart
            final Map<String, double> dailyMinutes = {};
            
            // Create appropriate date labels based on the time period
            if (widget.timePeriod == 'today') {
              // For today, show hours (morning, afternoon, evening, night)
              final List<String> timeSlots = ['Morning', 'Afternoon', 'Evening', 'Night'];
              for (var slot in timeSlots) {
                dailyMinutes[slot] = 0;
              }
              
              // Aggregate by time of day
              for (var session in filteredSessions) {
                String timeSlot;
                final hour = session.createdAt.hour;
                
                if (hour >= 5 && hour < 12) {
                  timeSlot = 'Morning'; // 5am-12pm
                } else if (hour >= 12 && hour < 17) {
                  timeSlot = 'Afternoon'; // 12pm-5pm
                } else if (hour >= 17 && hour < 21) {
                  timeSlot = 'Evening'; // 5pm-9pm
                } else {
                  timeSlot = 'Night'; // 9pm-5am
                }
                
                dailyMinutes[timeSlot] = (dailyMinutes[timeSlot] ?? 0) + session.durationMinutes;
              }
            } else if (widget.timePeriod == 'year') {
              // For year, show months
              for (int i = 11; i >= 0; i--) {
                final date = DateTime(now.year, now.month - i);
                final dateString = DateFormat('MMM').format(date);
                dailyMinutes[dateString] = 0;
              }
              
              // Aggregate by month
              for (var session in filteredSessions) {
                final dateString = DateFormat('MMM').format(session.createdAt);
                dailyMinutes[dateString] = (dailyMinutes[dateString] ?? 0) + session.durationMinutes;
              }
            } else if (widget.timePeriod == 'month') {
              // For month, show weeks
              for (int i = 0; i < 4; i++) {
                final weekStart = DateTime(now.year, now.month, 1 + (i * 7));
                final weekEnd = DateTime(now.year, now.month, 7 + (i * 7));
                final dateString = 'Week ${i + 1}';
                dailyMinutes[dateString] = 0;
              }
              
              // Aggregate by week of month
              for (var session in filteredSessions) {
                final day = session.createdAt.day;
                final weekNumber = ((day - 1) ~/ 7) + 1;
                final dateString = 'Week $weekNumber';
                dailyMinutes[dateString] = (dailyMinutes[dateString] ?? 0) + session.durationMinutes;
              }
            } else {
              // Default (week or custom): show daily
              final int daysToShow = widget.timePeriod == 'week' ? 7 : 7;
              for (int i = daysToShow - 1; i >= 0; i--) {
                final date = DateTime(now.year, now.month, now.day - i);
                final dateString = DateFormat('MMM d').format(date);
                dailyMinutes[dateString] = 0;
              }
              
              // Add session durations to the appropriate day
              for (var session in filteredSessions) {
                final sessionDate = DateTime(
                  session.createdAt.year,
                  session.createdAt.month,
                  session.createdAt.day,
                );
                
                final dateString = DateFormat('MMM d').format(sessionDate);
                if (dailyMinutes.containsKey(dateString)) {
                  dailyMinutes[dateString] = (dailyMinutes[dateString] ?? 0) + session.durationMinutes;
                }
              }
            }
            
            if (mounted) {
              setState(() {
                _sessions = filteredSessions;
                _dailyMinutes = dailyMinutes;
                _isLoading = false;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _errorMessage = 'Error loading data: ${error.toString()}';
                _isLoading = false;
              });
            }
          },
        );
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'You must be logged in to view analytics';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 250,
        child: Center(
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
        ),
      );
    }

    if (_sessions.isEmpty || _dailyMinutes.isEmpty) {
      return SizedBox(
        height: 250,
        child: Center(
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
        ),
      );
    }

    // Ensure we have valid data before rendering the chart
    if (_dailyMinutes.values.any((value) => value.isNaN || value.isInfinite)) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Text(
            'Error: Invalid data detected',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth;
        final maxBars = _calculateMaxBars(chartWidth);
        final adjustedData = _adjustDataForScreenSize(_dailyMinutes, maxBars);
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex < 0 || groupIndex >= adjustedData.length) {
                        return null;
                      }
                      final date = adjustedData.keys.elementAt(groupIndex);
                      final minutes = adjustedData[date]!.toInt();
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
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= adjustedData.length) {
                          return const SizedBox.shrink();
                        }
                        final date = adjustedData.keys.elementAt(value.toInt());
                        
                        // If we have many bars, use shorter labels
                        final label = adjustedData.length > 5 ? _getShortenedLabel(date) : date;
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Transform.rotate(
                            angle: adjustedData.length > 4 ? 0.3 : 0, // Only rotate if needed
                            child: SizedBox(
                              width: chartWidth / adjustedData.length - 10, // Dynamic width based on chart size
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45, // Increased space for y-axis labels
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '${value.toInt()} min',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
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
                barGroups: _buildBarGroups(adjustedData, chartWidth),
              ),
            ),
          ),
        );
      }
    );
  }

  // Shortened version of label for constrained space
  String _getShortenedLabel(String date) {
    // For date formats like "MMM d"
    if (date.contains(' ')) {
      final parts = date.split(' ');
      if (parts.length >= 2) {
        // First letter of month + day
        return '${parts[0][0]}${parts[1]}';
      }
    }
    
    // For time periods like "Morning"
    if (date.length > 4) {
      return date.substring(0, 4);
    }
    
    return date;
  }

  // Calculate how many bars can fit based on screen width
  int _calculateMaxBars(double width) {
    if (width < 300) return 4;
    if (width < 400) return 5;
    if (width < 500) return 6;
    return 7; // Default for larger screens
  }

  // Adjust data to fit screen size - either truncate or aggregate
  Map<String, double> _adjustDataForScreenSize(Map<String, double> data, int maxBars) {
    if (data.length <= maxBars) return data;
    
    // For larger datasets, we need to aggregate
    final Map<String, double> result = {};
    final entries = data.entries.toList();
    
    // Group data if needed
    if (widget.timePeriod == 'year' && maxBars < 12) {
      // Group months into quarters
      for (int i = 0; i < 4; i++) {
        final start = i * 3;
        final end = start + 2;
        final rangeEnd = end < entries.length ? end : entries.length - 1;
        double total = 0;
        for (int j = start; j <= rangeEnd && j < entries.length; j++) {
          total += entries[j].value;
        }
        result['Q${i+1}'] = total;
      }
      return result;
    }
    
    // Simple truncation for other cases - keep most recent data
    final recentEntries = entries.sublist(entries.length - maxBars);
    for (var entry in recentEntries) {
      result[entry.key] = entry.value;
    }
    return result;
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, double> data, double chartWidth) {
    final List<BarChartGroupData> groups = [];
    int index = 0;
    
    // Calculate bar width based on available space
    final barWidth = math.min(16.0, (chartWidth / data.length) - 16);
    
    for (final entry in data.entries) {
      // Skip NaN or infinite values
      if (entry.value.isNaN || entry.value.isInfinite) continue;
      
      groups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              width: barWidth, // Dynamic width based on available space
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
      index++;
    }
    
    return groups;
  }

  double _getMaxY() {
    if (_dailyMinutes.isEmpty) return 60; // Default
    
    final values = _dailyMinutes.values.where((v) => !v.isNaN && !v.isInfinite).toList();
    if (values.isEmpty) return 60;
    
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    // Round up to nearest multiple of the interval for neat chart
    final interval = _getInterval();
    return ((maxValue / interval).ceil() * interval) + interval;
  }

  double _getInterval() {
    if (_dailyMinutes.isEmpty) return 30; // Default
    
    final values = _dailyMinutes.values.where((v) => !v.isNaN && !v.isInfinite).toList();
    if (values.isEmpty) return 30;
    
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 60) return 15;
    if (maxValue <= 120) return 30;
    if (maxValue <= 240) return 60;
    return 120;
  }
} 