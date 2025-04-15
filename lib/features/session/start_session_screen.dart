import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
import '../../features/session/session_form_widget.dart';
import '../../models/study_session_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/quote_banner.dart';

class StartSessionScreen extends StatefulWidget {
  const StartSessionScreen({Key? key}) : super(key: key);

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  bool _isLoading = false;

  Future<void> _saveSession(StudySessionModel session) async {
    setState(() => _isLoading = true);
    
    try {
        final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      await firebaseService.saveStudySession(session);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session saved successfully!')),
        );
        Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Study Session'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const QuoteBanner(),
            const SizedBox(height: 24),
              
              if (authService.currentUser == null)
                const Center(child: Text('You must be logged in'))
              else
                Column(
                  children: [
                    SessionFormWidget(
                      userId: authService.currentUser!.uid,
                      onSessionCreated: _saveSession,
                    ),
                    
            CustomButton(
              text: 'Save Session',
                      onPressed: () {
                        // The form handles validation and submission
                        final formState = Form.of(context);
                        if (formState != null && formState.validate()) {
                          formState.save();
                        }
                      },
                      isLoading: _isLoading,
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
} 