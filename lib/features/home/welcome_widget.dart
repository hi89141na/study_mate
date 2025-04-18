import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/utils/constants.dart';
import '../../widgets/quote_banner.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({Key? key}) : super(key: key);

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when this widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthService>(context, listen: false).refreshUserData();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firebaseService = Provider.of<FirebaseService>(context);
    final user = authService.currentUser;
    
    // Get a better username with multiple fallbacks
    String displayName = 'Student';
    if (user?.displayName != null && user!.displayName.isNotEmpty) {
      displayName = user.displayName;
    } else if (authService.isAuthenticated) {
      // If we have Firebase auth but no display name, try to get email
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser?.email != null) {
        // Use the part before @ in the email
        displayName = firebaseUser!.email!.split('@')[0];
      }
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(displayName, context),
          const SizedBox(height: 24),
          const QuoteBanner(),
          const SizedBox(height: 24),
          if (user != null && user.uid.isNotEmpty) ...[
            _buildStatsSummary(user.uid, firebaseService, context),
            const SizedBox(height: 24),
          ],
          _buildQuickStartCard(context),
        ],
      ),
    );
  }

  Widget _buildGreeting(String name, BuildContext context) {
    final greeting = _getGreeting();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black54
                : Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Welcome to StudyMate',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(String userId, FirebaseService firebaseService, BuildContext context) {
    return FutureBuilder<int>(
      future: firebaseService.getTotalStudyMinutes(userId),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        // Handle error state
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Could not load stats',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          );
        }
        
        final totalMinutes = snapshot.data ?? 0;
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _statItem(
                        context,
                        icon: Icons.timer_outlined,
                        label: 'Study Time',
                        value: hours > 0 
                            ? '$hours hrs $minutes min'
                            : '$minutes min',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FutureBuilder<Map<String, int>>(
                        future: firebaseService.getSubjectDistribution(userId),
                        builder: (context, snapshot) {
                          // Add error handling
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ));
                          }
                          
                          if (snapshot.hasError) {
                            return _statItem(
                              context,
                              icon: Icons.book_outlined,
                              label: 'Subjects',
                              value: '-',
                            );
                          }
                          
                          final subjects = snapshot.data?.length ?? 0;
                          return _statItem(
                            context,
                            icon: Icons.book_outlined,
                            label: 'Subjects',
                            value: '$subjects',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black54
                : Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStartCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to start session screen
          Navigator.pushNamed(context, AppConstants.sessionRoute);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_task,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start a Study Session',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Log your study activity and track your progress',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black54
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }
} 