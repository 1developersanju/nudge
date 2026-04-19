import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/repository.dart';
import 'app_theme.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.repo});

  final LearningRepository repo;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late DateTime _selected;

  static DateTime _calendarDay(DateTime d) => DateTime(d.year, d.month, d.day);

  (DateTime safeFirst, DateTime last) _bounds() {
    final now = DateTime.now();
    final last = _calendarDay(now);
    final first = widget.repo.earliestSelectableLogDay();
    final safeFirst = first.isAfter(last)
        ? last.subtract(const Duration(days: 365))
        : first;
    return (safeFirst, last);
  }

  DateTime _clampToBounds(DateTime d, DateTime safeFirst, DateTime last) {
    var s = _calendarDay(d);
    if (s.isBefore(safeFirst)) s = safeFirst;
    if (s.isAfter(last)) s = last;
    return s;
  }

  void _syncSelectionToRepo() {
    final (lo, hi) = _bounds();
    final clamped = _clampToBounds(_selected, lo, hi);
    if (clamped != _selected) {
      if (mounted) setState(() => _selected = clamped);
    }
  }

  @override
  void initState() {
    super.initState();
    final (safeFirst, last) = _bounds();
    _selected = _clampToBounds(DateTime.now(), safeFirst, last);
    widget.repo.addListener(_syncSelectionToRepo);
  }

  @override
  void dispose() {
    widget.repo.removeListener(_syncSelectionToRepo);
    super.dispose();
  }

  ThemeData _calendarTheme(BuildContext context) {
    final base = Theme.of(context);
    final accentBorder = AppTheme.primary(context).withValues(alpha: 0.55);

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppTheme.primary(context),
        onPrimary: AppTheme.onPrimary(context),
        surface: AppTheme.surfaceContainerLow(context),
        onSurface: AppTheme.ink(context),
        onSurfaceVariant: AppTheme.muted(context),
        outline: AppTheme.outlineVariant(context).withValues(alpha: 0.22),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppTheme.surfaceContainerLow(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        weekdayStyle: TextStyle(
          color: AppTheme.muted(context).withValues(alpha: 0.95),
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
        dayStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          final isLight = Theme.of(context).brightness == Brightness.light;
          if (states.contains(WidgetState.selected)) {
            return isLight
                ? AppTheme.primaryContainer(context)
                : AppTheme.onPrimary(context);
          }
          if (states.contains(WidgetState.disabled)) {
            return AppTheme.muted(context).withValues(alpha: 0.4);
          }
          return AppTheme.ink(context);
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          final isLight = Theme.of(context).brightness == Brightness.light;
          if (states.contains(WidgetState.selected)) {
            return isLight
                ? AppTheme.primary(context).withValues(alpha: 0.15)
                : AppTheme.primary(context);
          }
          return Colors.transparent;
        }),

        yearStyle: const TextStyle(fontWeight: FontWeight.w600),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          final isLight = Theme.of(context).brightness == Brightness.light;
          if (states.contains(WidgetState.selected)) {
            return isLight
                ? AppTheme.primaryContainer(context)
                : AppTheme.onPrimary(context);
          }
          return AppTheme.ink(context);
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          final isLight = Theme.of(context).brightness == Brightness.light;
          if (states.contains(WidgetState.selected)) {
            return isLight
                ? AppTheme.primary(context).withValues(alpha: 0.15)
                : AppTheme.primary(context);
          }
          return Colors.transparent;
        }),
        dayOverlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppTheme.primary(context).withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return AppTheme.primary(context).withValues(alpha: 0.08);
          }
          return null;
        }),
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          final isLight = Theme.of(context).brightness == Brightness.light;
          if (states.contains(WidgetState.selected)) {
            return isLight
                ? AppTheme.primaryContainer(context)
                : AppTheme.onPrimary(context);
          }
          return AppTheme.primary(context);
        }),
        todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          final isLight = Theme.of(context).brightness == Brightness.light;
          if (states.contains(WidgetState.selected)) {
            return isLight
                ? AppTheme.primary(context).withValues(alpha: 0.15)
                : AppTheme.primary(context);
          }
          return AppTheme.primary(context).withValues(alpha: 0.1);
        }),
        todayBorder: BorderSide(color: accentBorder, width: 1.25),
      ),
    );
  }

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
  Widget build(BuildContext context) {
    final (safeFirst, last) = _bounds();
    final timeFmt = DateFormat.jm();

    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      appBar: AppBar(
        title: const Text(
          'Learning History',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: ColoredBox(
                  color: AppTheme.surfaceContainerLow(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Theme(
                      data: _calendarTheme(context),
                      child: CalendarDatePicker(
                        initialDate: _selected,
                        firstDate: safeFirst,
                        lastDate: last,
                        currentDate: DateTime.now(),
                        onDateChanged: (d) {
                          setState(() => _selected = _calendarDay(d));
                        },
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daily Snapshot',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary(context).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        DateFormat('EEE, MMM d').format(_selected),
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

              ListenableBuilder(
                listenable: widget.repo,
                builder: (context, _) {
                  final topics = widget.repo.topicsLoggedOnDay(_selected);
                  if (topics.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Center(
                        child: Text(
                          'No topics logged here',
                          style: TextStyle(
                            color: AppTheme.muted(context),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: topics.length,
                    itemBuilder: (context, i) {
                      final t = topics[i];

                      return Dismissible(
                        key: Key('history_${t.id}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => widget.repo.deleteTopic(t.id),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 24),
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
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 24,
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    if (i != topics.length - 1)
                                      Positioned.fill(
                                        top: 12,
                                        child: Container(
                                          width: 1,
                                          color: AppTheme.outlineVariant(
                                            context,
                                          ).withValues(alpha: 0.3),
                                        ),
                                      ),
                                    Positioned(
                                      top: 12,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary(context),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primaryContainer(
                                                context,
                                              ).withValues(alpha: 0.4),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainerLow(
                                      context,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.outlineVariant(
                                        context,
                                      ).withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            size: 14,
                                            color: AppTheme.muted(context),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            timeFmt.format(
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
                                              size: 14,
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
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
