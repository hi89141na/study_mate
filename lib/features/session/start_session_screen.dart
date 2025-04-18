import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../core/utils/constants.dart';
import '../../models/study_session_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../widgets/mood_selector.dart';
import '../../widgets/quote_banner.dart';

class StartSessionScreen extends StatefulWidget {
  const StartSessionScreen({Key? key}) : super(key: key);

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _reflectionController = TextEditingController();
  int _selectedDuration = 30; // Default 30 minutes
  int _selectedMood = 3; // Default neutral
  bool _isLoading = false;

  final List<int> _durationOptions = AppConstants.durationOptions;

  @override
  void dispose() {
    _subjectController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _saveSession() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final firebaseService = Provider.of<FirebaseService>(context, listen: false);
        
        if (authService.isAuthenticated) {
          // Refresh user data to ensure we have the latest information
          await authService.refreshUserData();
          
          // Get userId safely with null check
          final userId = authService.currentUser?.uid;
          if (userId == null || userId.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: Unable to retrieve user data. Please try logging out and back in.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() {
              _isLoading = false;
            });
            return;
          }
          
          final session = StudySessionModel(
            userId: userId,
            subject: _subjectController.text.trim(),
            durationMinutes: _selectedDuration,
            mood: _selectedMood,
            reflection: _reflectionController.text.trim(),
          );

          await firebaseService.saveStudySession(session);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Study session saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Clear form after successful save
            _subjectController.clear();
            _reflectionController.clear();
            setState(() {
              _selectedDuration = 30;
              _selectedMood = 3;
            });
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: You must be logged in to save a session'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving session: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if this screen is being shown in the HomeScreen tab navigation
    final bool isInTabNavigation = ModalRoute.of(context)?.settings.name != AppConstants.sessionRoute;
    
    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const QuoteBanner(),
            const SizedBox(height: 20),
            InputField(
              label: 'Subject/Topic',
              hint: 'What are you studying?',
              controller: _subjectController,
              prefixIcon: Icons.book_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a subject';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Study Duration (minutes)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black87
                    : Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _durationOptions.map((duration) {
                return ChoiceChip(
                  label: Text('$duration min'),
                  selected: _selectedDuration == duration,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDuration = duration;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            MoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) {
                setState(() {
                  _selectedMood = mood;
                });
              },
            ),
            const SizedBox(height: 20),
            InputField(
              label: 'Reflection',
              hint: 'How did the study session go? What did you learn?',
              controller: _reflectionController,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a reflection';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Save Session',
                onPressed: _saveSession,
                isLoading: _isLoading,
                icon: Icons.save_outlined,
              ),
            ),
          ],
        ),
      ),
    );
    
    // If we're in tab navigation, return just the content
    // Otherwise, wrap in a Scaffold with AppBar for standalone navigation
    if (isInTabNavigation) {
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Log Study Session'),
          actions: const [
            ThemeToggleButton(),
          ],
        ),
        body: content,
      );
    }
  }
} 