import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/repository.dart';
import '../theme/review_spacing_controller.dart';
import '../theme/theme_controller.dart';
import 'app_theme.dart';
import 'review_session_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repo,
    required this.theme,
    required this.spacing,
  });

  final LearningRepository repo;
  final ThemeController theme;
  final ReviewSpacingController spacing;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollCtrl = ScrollController();

  String _formatNextReview(DateTime dueAt, {bool includeTime = false}) {
    final now = DateTime.now();
    final d = dueAt.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(d.year, d.month, d.day);
    final diff = dueDay.difference(today).inDays;

    final timeStr = includeTime ? ' at ${DateFormat.jm().format(d)}' : '';

    if (diff < 0) return 'Review overdue';
    if (diff == 0) return 'Today$timeStr';
    if (diff == 1) return 'Tomorrow$timeStr';
    if (diff > 1 && diff <= 7) return 'in $diff days$timeStr';
    return '${DateFormat('MMM d').format(d)}$timeStr';
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sanctuary',
                      style: TextStyle(
                        color: AppTheme.primaryContainer(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(DateTime.now()),
                      style: TextStyle(
                        color: AppTheme.muted(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hero Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calm Command',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Memory Rhythm',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.primaryContainer(context),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Stats Grids
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListenableBuilder(
                  listenable: widget.repo,
                  builder: (context, _) {
                    final todayLogs = widget.repo
                        .topicsLoggedOnDay(DateTime.now())
                        .length;
                    final totalDue = widget.repo
                        .dueTopics(DateTime.now())
                        .length;

                    return Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Logged Today',
                            value: '$todayLogs',
                            icon: Icons.insights,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'Due Today',
                            value: '$totalDue',
                            icon: Icons.pending_actions,
                            isPrimary: true,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Due Review Session Module
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ListenableBuilder(
                  listenable: widget.repo,
                  builder: (context, _) {
                    final pending = widget.repo.dueTopics(DateTime.now());
                    if (pending.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow(context),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.outlineVariant(
                              context,
                            ).withValues(alpha: 0.1),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: AppTheme.primaryContainer(context),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'All clear',
                                style: TextStyle(
                                  color: AppTheme.muted(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReviewSessionScreen(
                              repo: widget.repo,
                              topics: pending,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary(context),
                              AppTheme.primaryContainer(context),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary(
                                context,
                              ).withValues(alpha: 0.2),
                              blurRadius: 32,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: CircularProgressIndicator(
                                    value: 1.0,
                                    strokeWidth: 4,
                                    backgroundColor: AppTheme.onPrimary(
                                      context,
                                    ).withValues(alpha: 0.2),
                                    color: AppTheme.onPrimary(context),
                                  ),
                                ),
                                Icon(
                                  Icons.play_arrow_rounded,
                                  color: AppTheme.onPrimary(context),
                                  size: 32,
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Review Sessions',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.onPrimary(context),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${pending.length} Topics pending',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.onPrimary(
                                        context,
                                      ).withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Today's Captures Title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'Today\'s Captures',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),

            // Today's Captures List
            ListenableBuilder(
              listenable: widget.repo,
              builder: (context, _) {
                final topics = widget.repo.topicsLoggedOnDay(DateTime.now());
                if (topics.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Your mind is empty today.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.muted(context),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 120,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final t = topics[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: Key('home_${t.id}'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => widget.repo.deleteTopic(t.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLow(context),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceContainerHighest(
                                          context,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.description_outlined,
                                        size: 16,
                                        color: AppTheme.muted(context),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        t.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 12,
                                      color: AppTheme.muted(context),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat.jm().format(
                                        t.createdAt.toLocal(),
                                      ),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.muted(context),
                                      ),
                                    ),
                                    if (t.nextPending() != null) ...[
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.event_repeat,
                                        size: 12,
                                        color: AppTheme.muted(context),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Next: ${_formatNextReview(t.nextPending()!.dueAt)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.muted(context),
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary(
                                          context,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'NEW',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                          color: AppTheme.primary(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: topics.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isPrimary;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppTheme.surfaceContainer(context)
            : AppTheme.surfaceContainerLow(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPrimary
              ? AppTheme.primary(context).withValues(alpha: 0.3)
              : AppTheme.outlineVariant(context).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: isPrimary
                    ? AppTheme.primaryContainer(context)
                    : AppTheme.muted(context),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isPrimary
                      ? AppTheme.primary(context)
                      : AppTheme.ink(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.muted(context),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
