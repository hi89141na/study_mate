import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';

class SubjectPieChart extends StatefulWidget {
  const SubjectPieChart({Key? key}) : super(key: key);

  @override
  State<SubjectPieChart> createState() => _SubjectPieChartState();
}

class _SubjectPieChartState extends State<SubjectPieChart> {
  bool _isLoading = true;
  Map<String, int> _subjectDistribution = {};
  String? _errorMessage;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      if (authService.currentUser != null) {
        final userId = authService.currentUser!.uid;
        final subjectDistribution = await firebaseService.getSubjectDistribution(userId);
        
        setState(() {
          _subjectDistribution = subjectDistribution;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'You must be logged in to view analytics';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_subjectDistribution.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pie_chart,
              color: Colors.grey,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Subject Data Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking study sessions to see your subject distribution',
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
      );
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: _buildSections(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = _subjectDistribution.values.fold<int>(0, (sum, value) => sum + value);
    final subjects = _subjectDistribution.keys.toList();
    
    // Generate colors for each subject
    final colors = _generateColors(subjects.length);
    
    return List.generate(subjects.length, (index) {
      final subject = subjects[index];
      final minutes = _subjectDistribution[subject] ?? 0;
      final percentage = (minutes / total) * 100;
      
      final isTouched = index == _touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: minutes.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend() {
    final subjects = _subjectDistribution.keys.toList();
    final colors = _generateColors(subjects.length);
    
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final minutes = _subjectDistribution[subject] ?? 0;
          final hours = (minutes / 60.0).toStringAsFixed(1);
          
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$hours hours',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black54
                              : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Color> _generateColors(int count) {
    final baseColors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    
    if (count <= baseColors.length) {
      return baseColors.sublist(0, count);
    }
    
    // For more subjects, generate additional colors
    List<Color> colors = List.from(baseColors);
    
    for (int i = baseColors.length; i < count; i++) {
      final shade = (i % 3) * 100 + 300; // Generates shades 300, 400, 500
      final baseIndex = i % baseColors.length;
      
      // Create a slightly different shade of the base color
      colors.add(
        baseColors[baseIndex] is MaterialColor
            ? (baseColors[baseIndex] as MaterialColor)[shade] ?? baseColors[baseIndex]
            : baseColors[baseIndex],
      );
    }
    
    return colors;
  }
}