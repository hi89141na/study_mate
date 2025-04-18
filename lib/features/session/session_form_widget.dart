import 'package:flutter/material.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/enums.dart';
import '../../models/study_session_model.dart';
import '../../widgets/input_field.dart';
import '../../widgets/mood_selector.dart';

class SessionFormWidget extends StatefulWidget {
  final Function(StudySessionModel) onSessionCreated;
  final String userId;

  const SessionFormWidget({
    Key? key,
    required this.onSessionCreated,
    required this.userId,
  }) : super(key: key);

  @override
  State<SessionFormWidget> createState() => _SessionFormWidgetState();
}

class _SessionFormWidgetState extends State<SessionFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _reflectionController = TextEditingController();
  MoodType _selectedMood = MoodType.neutral;
  int _selectedDuration = AppConstants.defaultDuration;

  @override
  void dispose() {
    _subjectController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final session = StudySessionModel(
        userId: widget.userId,
        subject: _subjectController.text.trim(),
        durationMinutes: _selectedDuration,
        mood: _selectedMood.value,
        reflection: _reflectionController.text.trim(),
      );
      
      widget.onSessionCreated(session);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputField(
            label: 'Subject/Title',
            controller: _subjectController,
            hint: 'Enter subject or title',
            prefixIcon: Icons.book_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a subject';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDurationSelector(),
          const SizedBox(height: 16),
          MoodSelector(
            selectedMood: _selectedMood.value,
            onMoodSelected: (mood) {
              setState(() {
                // Convert int to MoodType
                switch (mood) {
                  case 1:
                    _selectedMood = MoodType.great;
                    break;
                  case 2:
                    _selectedMood = MoodType.good;
                    break;
                  case 3:
                    _selectedMood = MoodType.neutral;
                    break;
                  case 4:
                    _selectedMood = MoodType.tired;
                    break;
                  case 5:
                    _selectedMood = MoodType.stressed;
                    break;
                }
              });
            },
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'Reflection',
            controller: _reflectionController,
            hint: 'Your reflection on this study session...',
            prefixIcon: Icons.edit_note,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please add a brief reflection';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration (minutes)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedDuration,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            prefixIcon: const Icon(Icons.timer),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: AppConstants.durationOptions.map((int duration) {
            return DropdownMenuItem<int>(
              value: duration,
              child: Text('$duration minutes'),
            );
          }).toList(),
          onChanged: (int? value) {
            if (value != null) {
              setState(() => _selectedDuration = value);
            }
          },
        ),
      ],
    );
  }
} 