import 'package:flutter/material.dart';
import '../../models/study_session_model.dart';

class MoodSelector extends StatelessWidget {
  final MoodType selectedMood;
  final Function(MoodType) onMoodSelected;

  const MoodSelector({
    Key? key,
    required this.selectedMood,
    required this.onMoodSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How do you feel?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black87
                : Colors.white70,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMoodOption(
              context, 
              MoodType.great, 
              '😁', 
              'Great',
            ),
            _buildMoodOption(
              context, 
              MoodType.good, 
              '🙂', 
              'Good',
            ),
            _buildMoodOption(
              context, 
              MoodType.neutral, 
              '😐', 
              'Neutral',
            ),
            _buildMoodOption(
              context, 
              MoodType.tired, 
              '😴', 
              'Tired',
            ),
            _buildMoodOption(
              context, 
              MoodType.stressed, 
              '😰', 
              'Stressed',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodOption(
    BuildContext context, 
    MoodType mood, 
    String emoji, 
    String label,
  ) {
    final isSelected = selectedMood == mood;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onMoodSelected(mood),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.brightness == Brightness.light
                      ? Colors.black87
                      : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}