import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../core/utils/constants.dart';
import '../../features/history/calendar_view.dart';
import '../../features/home/welcome_widget.dart';
import '../../widgets/quote_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WelcomeWidget(),
              const SizedBox(height: 24),
              const QuoteBanner(),
              const SizedBox(height: 32),
              Text(
                'What would you like to do today?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                title: 'Start Study Session',
                icon: Icons.timer,
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.sessionRoute);
                },
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                title: 'Session History',
                icon: Icons.history,
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.historyRoute);
                },
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                title: 'Calendar View',
                icon: Icons.calendar_today,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalendarView()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                title: 'Analytics',
                icon: Icons.bar_chart,
                color: Colors.purple,
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.analyticsRoute);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
} 