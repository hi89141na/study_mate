import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/study_session_model.dart';

class MoodChart extends StatelessWidget {
  final List<StudySessionModel> sessions;

  const MoodChart({
    Key? key,
    required this.sessions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final moodData = _prepareMoodData();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(context).colorScheme.surfaceVariant,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = moodData.keys.elementAt(spot.x.toInt());
                final moodIndex = spot.y.toInt();
                final moodName = MoodType.values[moodIndex].toString().split('.').last;
                
                return LineTooltipItem(
                  '$date\n$moodName',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= moodData.length || value.toInt() < 0) {
                  return const SizedBox.shrink();
                }
                
                final date = moodData.keys.elementAt(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    date,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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
                if (value < 0 || value >= MoodType.values.length) {
                  return const SizedBox.shrink();
                }
                
                final mood = MoodType.values[value.toInt()];
                String emoji = '😐'; // Default to neutral emoji
                
                switch (mood) {
                  case MoodType.great:
                    emoji = '😁';
                    break;
                  case MoodType.good:
                    emoji = '🙂';
                    break;
                  case MoodType.neutral:
                    emoji = '😐';
                    break;
                  case MoodType.tired:
                    emoji = '😴';
                    break;
                  case MoodType.stressed:
                    emoji = '😰';
                    break;
                  default:
                    emoji = '😐';
                    break;
                }
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
            left: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        minX: 0,
        maxX: moodData.length - 1.0,
        minY: 0,
        maxY: MoodType.values.length - 1.0,
        lineBarsData: [
          LineChartBarData(
            spots: _createSpots(moodData),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: Theme.of(context).colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _prepareMoodData() {
    // Group sessions by date and calculate average mood
    final Map<DateTime, List<int>> moodsByDate = {};
    
    for (final session in sessions) {
      final date = DateTime(
        session.createdAt.year,
        session.createdAt.month,
        session.createdAt.day,
      );
      
      if (!moodsByDate.containsKey(date)) {
        moodsByDate[date] = [];
      }
      
      moodsByDate[date]!.add(session.mood.index);
    }
    
    // Calculate average mood for each date
    final Map<String, double> result = {};
    final sortedDates = moodsByDate.keys.toList()..sort();
    
    for (final date in sortedDates) {
      final moods = moodsByDate[date]!;
      final avgMood = moods.reduce((a, b) => a + b) / moods.length;
      final formattedDate = DateFormat('M/d').format(date);
      result[formattedDate] = avgMood;
    }
    
    return result;
  }

  List<FlSpot> _createSpots(Map<String, double> moodData) {
    final spots = <FlSpot>[];
    
    int index = 0;
    for (final mood in moodData.values) {
      spots.add(FlSpot(index.toDouble(), mood));
      index++;
    }
    
    return spots;
  }
} 