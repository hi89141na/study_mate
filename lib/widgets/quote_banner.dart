import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['quote'] as String,
      author: json['author'] as String,
    );
  }
}

class QuoteBanner extends StatefulWidget {
  const QuoteBanner({Key? key}) : super(key: key);

  @override
  State<QuoteBanner> createState() => _QuoteBannerState();
}

class _QuoteBannerState extends State<QuoteBanner> {
  List<Quote> _quotes = [];
  Quote? _currentQuote;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/quotes.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      setState(() {
        _quotes = jsonList.map((json) => Quote.fromJson(json)).toList();
        _selectRandomQuote();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentQuote = Quote(
          text: "Learning is a treasure that will follow its owner everywhere.",
          author: "Chinese Proverb",
        );
        _isLoading = false;
      });
    }
  }

  void _selectRandomQuote() {
    if (_quotes.isEmpty) return;
    
    final random = Random();
    final index = random.nextInt(_quotes.length);
      _currentQuote = _quotes[index];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentQuote == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.format_quote,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentQuote!.text,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "- ${_currentQuote!.author}",
            style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
            ),
          ),
          const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _selectRandomQuote();
                  });
                },
                tooltip: 'New quote',
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
        ),
      ),
    );
  }
} 