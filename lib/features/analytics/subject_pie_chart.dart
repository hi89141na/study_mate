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

    // Use a SingleChildScrollView to prevent overflow
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 250, // Slightly reduce height to allow more space for legend
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
          const SizedBox(height: 16), // Reduced spacing
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
      
      // Only show percentage label for sections that are large enough (>= 10%)
      final String title = percentage >= 10 ? '${percentage.toStringAsFixed(0)}%' : '';
      
      sections.add(
        PieChartSectionData(
          color: _getSubjectColor(colorIndex),
          value: duration.toDouble(),
          title: title,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      // Use SingleChildScrollView to make legend scrollable if needed
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8, // Reduced spacing
        runSpacing: 8, // Reduced spacing
        children: List.generate(subjectData.length, (index) {
          final subject = subjectData.keys.elementAt(index);
          final duration = subjectData[subject] ?? 0;
          final hours = duration ~/ 60;
          final minutes = duration % 60;
          
          // More concise time string format
          String timeString;
          if (hours > 0) {
            timeString = '$hours h';
            if (minutes > 0) timeString += ' ${minutes}m';
          } else {
            timeString = '$minutes min';
          }
          
          // Limit subject length to prevent overflow
          final displaySubject = subject.length > 15 
            ? '${subject.substring(0, 15)}...' 
            : subject;
          
          return Container(
            constraints: const BoxConstraints(maxWidth: 180), // Limit max width
            margin: const EdgeInsets.only(bottom: 4), // Add bottom margin
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getSubjectColor(index), width: 1.5),
            ),
            child: Row(
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
                const SizedBox(width: 4), // Reduced spacing
                // Use Flexible to allow text to wrap if needed
                Flexible(
                  child: Text(
                    '$displaySubject ($timeString)',
                    style: TextStyle(
                      fontSize: 11, // Smaller font
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black87
                          : Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1, // Restrict to single line
                  ),
                ),
              ],
            ),
          );
        }),
      ),
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