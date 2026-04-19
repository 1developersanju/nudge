import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/scheduling_profile.dart';
import 'app_theme.dart';

/// How the user specifies each revisit gap before converting to stored minutes.
enum RevisitGapUnit { minutes, hours, days, weeks, monthsApprox }

extension on RevisitGapUnit {
  String get title => switch (this) {
    RevisitGapUnit.minutes => 'Minutes',
    RevisitGapUnit.hours => 'Hours',
    RevisitGapUnit.days => 'Days',
    RevisitGapUnit.weeks => 'Weeks',
    RevisitGapUnit.monthsApprox => 'Months (~30 d)',
  };
}

int _minutesPerUnit(RevisitGapUnit u) => switch (u) {
  RevisitGapUnit.minutes => 1,
  RevisitGapUnit.hours => 60,
  RevisitGapUnit.days => 24 * 60,
  RevisitGapUnit.weeks => 7 * 24 * 60,
  RevisitGapUnit.monthsApprox => 30 * 24 * 60,
};

int _toStorageMinutes(int amount, RevisitGapUnit unit) {
  if (amount < 1) return 0;
  return amount * _minutesPerUnit(unit);
}

/// Picks the largest unit that divides [minutes] evenly (for sensible defaults).
(RevisitGapUnit unit, int amount) _decomposeForDisplay(int minutes) {
  if (minutes < 1) return (RevisitGapUnit.minutes, 1);
  const order = [
    RevisitGapUnit.monthsApprox,
    RevisitGapUnit.weeks,
    RevisitGapUnit.days,
    RevisitGapUnit.hours,
    RevisitGapUnit.minutes,
  ];
  for (final u in order) {
    final per = _minutesPerUnit(u);
    if (minutes % per == 0) {
      final n = minutes ~/ per;
      if (n >= 1) return (u, n);
    }
  }
  return (RevisitGapUnit.minutes, minutes);
}

String _humanPreview(int totalMinutes) {
  final (u, n) = _decomposeForDisplay(totalMinutes);
  if (u == RevisitGapUnit.minutes) return '$n min';
  if (u == RevisitGapUnit.hours) return n == 1 ? '1 hour' : '$n hours';
  if (u == RevisitGapUnit.days) return n == 1 ? '1 day' : '$n days';
  if (u == RevisitGapUnit.weeks) return n == 1 ? '1 week' : '$n weeks';
  return n == 1 ? '~1 month' : '~$n months';
}

class _GapRowControllers {
  factory _GapRowControllers(int initialMinutes) {
    final p = _decomposeForDisplay(initialMinutes);
    return _GapRowControllers._(TextEditingController(text: '${p.$2}'), p.$1);
  }

  _GapRowControllers._(this.amount, this.unit);

  final TextEditingController amount;
  RevisitGapUnit unit;

  void dispose() => amount.dispose();
}

class CustomRevisitSpacingDialog extends StatefulWidget {
  final List<int> initialMinutes;
  const CustomRevisitSpacingDialog({super.key, required this.initialMinutes});

  @override
  State<CustomRevisitSpacingDialog> createState() =>
      _CustomRevisitSpacingDialogState();
}

class _CustomRevisitSpacingDialogState
    extends State<CustomRevisitSpacingDialog> {
  late final List<_GapRowControllers> rows;
  String? err;

  @override
  void initState() {
    super.initState();
    rows = [
      _GapRowControllers(widget.initialMinutes[0]),
      _GapRowControllers(widget.initialMinutes[1]),
      _GapRowControllers(widget.initialMinutes[2]),
    ];
  }

  @override
  void dispose() {
    for (final r in rows) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom revisit timing'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Each revisit is scheduled after you log the topic (from that moment), '
              'not from a fixed calendar date. Choose how long to wait before each reminder.',
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppTheme.muted(context).withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Months use 30 days on average so scheduling can use a single stored value.',
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: AppTheme.muted(context).withValues(alpha: 0.75),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              Text(
                i == 0
                    ? '1st revisit after logging'
                    : i == 1
                    ? '2nd revisit after logging'
                    : '3rd revisit after logging',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.muted(context).withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: rows[i].amount,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() => err = null),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<RevisitGapUnit>(
                      key: ValueKey<String>('unit_${i}_${rows[i].unit.name}'),
                      value: rows[i].unit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        isDense: true,
                      ),
                      items: RevisitGapUnit.values
                          .map(
                            (u) => DropdownMenuItem(
                              value: u,
                              child: Text(u.title),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          rows[i].unit = v;
                          err = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Builder(
                builder: (_) {
                  final n = int.tryParse(rows[i].amount.text.trim());
                  if (n == null || n < 1) return const SizedBox.shrink();
                  final m = _toStorageMinutes(n, rows[i].unit);
                  if (m < 1 || m > SchedulingProfile.maxCustomMinutes) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Stored as $m minutes total (~${_humanPreview(m)})',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.muted(context).withValues(alpha: 0.8),
                      ),
                    ),
                  );
                },
              ),
            ],
            if (err != null) ...[
              const SizedBox(height: 10),
              Text(
                err!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final out = <int>[];
            for (final r in rows) {
              final n = int.tryParse(r.amount.text.trim());
              if (n == null || n < 1) {
                setState(
                  () => err = 'Enter a positive whole number for each revisit.',
                );
                return;
              }
              final m = _toStorageMinutes(n, r.unit);
              final maxM = SchedulingProfile.maxCustomMinutes;
              if (m < 1 || m > maxM) {
                setState(
                  () => err =
                      'Each gap must be between 1 minute and $maxM minutes when converted.',
                );
                return;
              }
              out.add(m);
            }
            if (!SchedulingProfile.isValidCustomMinutesList(out)) {
              setState(() => err = 'Those values are not valid together.');
              return;
            }
            Navigator.pop(context, out);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

Future<List<int>?> showCustomRevisitSpacingDialog(
  BuildContext context, {
  required List<int> initialMinutes,
}) async {
  return showDialog<List<int>>(
    context: context,
    builder: (ctx) =>
        CustomRevisitSpacingDialog(initialMinutes: initialMinutes),
  );
}
