import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
import '../../features/history/session_card_widget.dart';
import '../../models/study_session_model.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  List<StudySessionModel> _sessions = [];
  String? _errorMessage;
  StreamSubscription<List<StudySessionModel>>? _sessionsSubscription;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _sessionsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      if (authService.currentUser != null) {
        final userId = authService.currentUser!.uid;
        // Cancel any existing subscription
        _sessionsSubscription?.cancel();
        
        // Subscribe to the stream
        _sessionsSubscription = firebaseService.getStudySessions(userId).listen(
          (sessions) {
            setState(() {
              _sessions = sessions;
              _isLoading = false;
            });
          },
          onError: (error) {
            setState(() {
              _errorMessage = 'Error loading sessions: ${error.toString()}';
              _isLoading = false;
            });
          }
        );
      } else {
        setState(() {
          _errorMessage = 'You must be logged in to view sessions';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading sessions: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadSessions,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.history,
                color: Colors.grey,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Study Sessions Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start a new study session to track your progress',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black54
                      : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group sessions by date
    Map<String, List<StudySessionModel>> groupedSessions = {};
    for (var session in _sessions) {
      final dateKey = DateFormat('MMMM d, y').format(session.createdAt);
      if (!groupedSessions.containsKey(dateKey)) {
        groupedSessions[dateKey] = [];
      }
      groupedSessions[dateKey]!.add(session);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedSessions.keys.length,
      itemBuilder: (context, index) {
        final dateKey = groupedSessions.keys.elementAt(index);
        final dateSessions = groupedSessions[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                dateKey,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...dateSessions.map((session) => SessionCardWidget(session: session)),
            if (index < groupedSessions.keys.length - 1)
              const Divider(height: 32),
          ],
        );
      },
    );
  }
} 