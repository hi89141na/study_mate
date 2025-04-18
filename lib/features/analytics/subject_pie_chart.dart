import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
import 'dart:math' as math;

class SubjectPieChart extends StatelessWidget {
  final Map<String, int> subjectData;

  const SubjectPieChart({
    Key? key,
    required this.subjectData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check for empty data
    if (subjectData.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text('No subject data available'),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _createSections(),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    // Handle touch events if needed
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(context),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createSections() {
    final List<PieChartSectionData> sections = [];
    
    if (subjectData.isEmpty) return sections;
    
    int totalDuration = 0;
    subjectData.forEach((_, duration) => totalDuration += duration);
    
    // Guard against division by zero
    if (totalDuration <= 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: 'No data',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )
      ];
    }
    
    int colorIndex = 0;
    subjectData.forEach((subject, duration) {
      final double percentage = (duration / totalDuration) * 100;
      
      sections.add(
        PieChartSectionData(
          color: _getSubjectColor(colorIndex),
          value: duration.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      
      colorIndex++;
    });
    
    return sections;
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: List.generate(subjectData.length, (index) {
        final subject = subjectData.keys.elementAt(index);
        final duration = subjectData[subject] ?? 0;
        final hours = duration ~/ 60;
        final minutes = duration % 60;
        final timeString = hours > 0 
            ? '$hours hrs ${minutes > 0 ? '$minutes min' : ''}'
            : '$minutes min';
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getSubjectColor(index),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$subject ($timeString)',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black87
                    : Colors.white70,
              ),
            ),
          ],
        );
      }),
    );
  }

  Color _getSubjectColor(int index) {
    // A list of colors for the pie chart sections
    const colors = [
      Color(0xFF2196F3), // Blue
      Color(0xFF4CAF50), // Green
      Color(0xFFFF9800), // Orange
      Color(0xFF9C27B0), // Purple
      Color(0xFFE91E63), // Pink
      Color(0xFF00BCD4), // Cyan
      Color(0xFFFFEB3B), // Yellow
      Color(0xFF795548), // Brown
      Color(0xFF607D8B), // Blue Grey
    ];
    
    if (index < colors.length) {
      return colors[index];
    } else {
      // Generate a random color for subjects beyond our predefined colors
      return Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    }
  }
}