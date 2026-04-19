import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/repository.dart';
import 'app_theme.dart';

class ReviewSessionScreen extends StatefulWidget {
  final LearningRepository repo;
  final List<LearningTopic> topics;

  const ReviewSessionScreen({
    super.key,
    required this.repo,
    required this.topics,
  });

  @override
  State<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends State<ReviewSessionScreen> {
  int _currentIndex = 0;

  void _onProcess(LearningTopic t, bool recallSuccess) async {
    if (recallSuccess) {
      await widget.repo.completeNextReview(t.id);
    } else {
      await widget.repo.snoozeNextReview(t.id);
    }
    if (_currentIndex < widget.topics.length - 1) {
      if (mounted) setState(() => _currentIndex++);
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.topics.isEmpty || _currentIndex >= widget.topics.length) {
      return Scaffold(
        backgroundColor: AppTheme.surface(context),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Text(
            "All Done",
            style: TextStyle(color: AppTheme.ink(context)),
          ),
        ),
      );
    }

    final current = widget.topics[_currentIndex];

    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${widget.topics.length}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Text(
                    current.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => _onProcess(current, false),
                      child: Text(
                        'Review Again',
                        style: TextStyle(color: AppTheme.muted(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary(context),
                        foregroundColor: AppTheme.onPrimary(context),
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => _onProcess(current, true),
                      child: const Text(
                        'Revised',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
