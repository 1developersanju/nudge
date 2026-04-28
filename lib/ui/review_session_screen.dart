import 'dart:async';
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
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onProcess(LearningTopic t, bool recallSuccess) async {
    if (recallSuccess) {
      await widget.repo.completeNextReview(t.id);
    } else {
      await widget.repo.snoozeNextReview(t.id);
    }
    if (mounted) {
      if (widget.repo.dueTopics(DateTime.now()).isEmpty) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repo,
      builder: (context, _) {
        final pending = widget.repo.dueTopics(DateTime.now());

        if (pending.isEmpty) {
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

        final progress = widget.repo.reviewProgress(DateTime.now());

        return Scaffold(
          backgroundColor: AppTheme.surface(context),
          appBar: AppBar(
            title: Text('${progress.$1} / ${progress.$2} Completed'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: pending.length,
              itemBuilder: (context, index) {
                final current = pending[index];
            final dueEvent = current.nextPendingDue(DateTime.now());
            String waveText = '';
            if (dueEvent != null) {
              switch (dueEvent.wave) {
                case ReviewWave.day1:
                  waveText = '1st Review';
                  break;
                case ReviewWave.day7:
                  waveText = '2nd Review';
                  break;
                case ReviewWave.day30:
                  waveText = '3rd Review';
                  break;
              }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.outlineVariant(context).withValues(alpha: 0.1),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (waveText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryContainer(context).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              waveText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    current.captureDisplayText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: AppTheme.ink(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _onProcess(current, false),
                          child: Text(
                            'Review Again',
                            style: TextStyle(color: AppTheme.muted(context)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary(context),
                            foregroundColor: AppTheme.onPrimary(context),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
                ],
              ),
            );
          },
        ),
              },
            ),
          ),
        );
      },
    );
  }
}
