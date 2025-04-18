import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/study_session_model.dart';
import '../../core/utils/constants.dart';

class MoodChart extends StatelessWidget {
  final Map<int, int> moodData;

  const MoodChart({
    Key? key,
    required this.moodData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if there's any valid data
    if (moodData.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text('No mood data available'),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: Column(
        children: [
          _buildChart(context),
          const SizedBox(height: 16),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    // Calculate the max value for better scaling
    int maxValue = 0;
    moodData.forEach((_, count) {
      if (count > maxValue) maxValue = count;
    });
    
    // If no data or all zeros, show placeholder
    if (maxValue == 0) {
      return const Expanded(
        child: Center(
          child: Text('No mood data recorded yet'),
        ),
      );
    }

    return Expanded(
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * 1.2, // 20% margin at the top for better visibility
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (group.x < 1 || group.x > 5) return null;
                
                return BarTooltipItem(
                  '${rod.toY.round()} sessions',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final mood = value.toInt();
                  if (mood < 1 || mood > 5) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      AppConstants.moodEmojis[mood] ?? '',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value != value.toInt() || value < 0) return const SizedBox.shrink();
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black54
                          : Colors.white70,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 25,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black12
                    : Colors.white12,
                strokeWidth: 1,
              );
            },
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: _getBarGroups(context),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      children: List.generate(5, (index) {
        final moodNumber = index + 1;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppConstants.moodEmojis[moodNumber] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              AppConstants.moodDescriptions[moodNumber] ?? '',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black54
                    : Colors.white70,
              ),
            ),
          ],
        );
      }),
    );
  }

  List<BarChartGroupData> _getBarGroups(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    
    for (int mood = 1; mood <= 5; mood++) {
      final count = moodData[mood] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: mood,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: _getMoodColor(mood, context),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    
    return barGroups;
  }
  
  Color _getMoodColor(int mood, BuildContext context) {
    switch (mood) {
      case 1: return Colors.green;  // Great
      case 2: return Colors.lightGreen;  // Good
      case 3: return Colors.amber;  // Neutral
      case 4: return Colors.orange;  // Tired
      case 5: return Colors.red;  // Stressed
      default: return Theme.of(context).colorScheme.primary;
    }
  }
} 