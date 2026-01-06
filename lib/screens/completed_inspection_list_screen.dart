import 'package:flutter/material.dart';
import '../models/ui_models.dart';

/// A read-only "review" list for completed inspections.
/// Shows aircraft, opened/completed timestamps, and the list of tasks completed.
///
/// Different look vs other list screens:
/// - Card header with a status pill
/// - "Timeline" row showing Opened -> Completed
/// - Expandable task list for each inspection (keeps the list scannable)
class CompletedInspectionListScreen extends StatelessWidget {
  final List<InspectionUi> completedInspections;

  /// All tasks (we'll group by inspectionId).
  final List<TaskUi> allTasks;

  const CompletedInspectionListScreen({
    super.key,
    required this.completedInspections,
    required this.allTasks,
  });

  @override
  Widget build(BuildContext context) {
    final inspections = [...completedInspections];

    // Sort: newest completed first (fallback to openedAt if needed)
    inspections.sort((a, b) {
      final aTime = a.closedAt ?? a.openedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.closedAt ?? b.openedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    // Group tasks by inspection id
    final tasksByInspection = <String, List<TaskUi>>{};
    for (final t in allTasks) {
      final key = t.inspectionId;
      tasksByInspection.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Completed Inspections'),
      ),
      body: inspections.isEmpty
          ? _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: inspections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final insp = inspections[index];
                final tasks = (tasksByInspection[insp.id] ?? [])
                  ..sort((a, b) {
                    final ac = (a.code ?? '').compareTo(b.code ?? '');
                    if (ac != 0) return ac;
                    return a.title.compareTo(b.title);
                  });

                return _CompletedInspectionCard(
                  inspection: insp,
                  tasks: tasks,
                );
              },
            ),
    );
  }
}

class _CompletedInspectionCard extends StatelessWidget {
  final InspectionUi inspection;
  final List<TaskUi> tasks;

  const _CompletedInspectionCard({
    required this.inspection,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final aircraft = (inspection.aircraftTailNumber ?? '').trim().isNotEmpty
        ? inspection.aircraftTailNumber!.trim()
        : 'Aircraft —';

    final openedAt = inspection.openedAt;
    final completedAt = inspection.closedAt;

    final openedText = openedAt == null ? 'Opened: —' : 'Opened: ${_fmtDateTime(openedAt)}';
    final completedText =
        completedAt == null ? 'Completed: —' : 'Completed: ${_fmtDateTime(completedAt)}';

    final taskCount = tasks.length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row (aircraft + status pill)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    aircraft,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                _StatusPill(
                  label: 'COMPLETED',
                  icon: Icons.check_circle,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // "Timeline" look: Opened -> Completed
            _TimelineRow(
              leftText: openedText,
              rightText: completedText,
            ),

            const SizedBox(height: 10),

            // Summary strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
              ),
              child: Row(
                children: [
                  const Icon(Icons.playlist_add_check, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$taskCount task${taskCount == 1 ? '' : 's'} completed',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    'Read-only',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Expandable tasks (keeps list compact; still meets "show tasks" requirement)
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 6, bottom: 8),
                title: Text(
                  'Tasks on this jet',
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  taskCount == 0 ? 'No tasks found' : 'Tap to review',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                  ),
                ),
                trailing: const Icon(Icons.expand_more),
                children: [
                  if (tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'No tasks were recorded for this inspection.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                    )
                  else
                    _TaskReviewList(tasks: tasks),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskReviewList extends StatelessWidget {
  final List<TaskUi> tasks;

  const _TaskReviewList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: tasks.map((t) {
        final code = (t.code ?? '').trim();
        final result = (t.result ?? '—').trim();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Small "badge" area
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
                ),
                child: const Icon(Icons.task_alt, size: 18),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          code.isEmpty ? 'Code: —' : 'Code: $code',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Result: $result',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String leftText;
  final String rightText;

  const _TimelineRow({
    required this.leftText,
    required this.rightText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final faded = theme.textTheme.bodySmall?.color?.withOpacity(0.75);

    return Row(
      children: [
        // Left point
        _Dot(color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            leftText,
            style: theme.textTheme.bodySmall?.copyWith(color: faded),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Line
        Container(
          width: 26,
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: theme.dividerColor.withOpacity(0.9),
          ),
        ),
        // Right point
        _Dot(color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            rightText,
            style: theme.textTheme.bodySmall?.copyWith(color: faded),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatusPill({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.primary.withOpacity(0.10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.45),
            ),
            const SizedBox(height: 12),
            Text(
              'No completed inspections yet',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed inspections will appear here for review.\nThis screen is read-only.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtDateTime(DateTime dt) {
  // Lightweight, dependency-free formatting: 05 Jan 2026 • 14:03
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final dd = dt.day.toString().padLeft(2, '0');
  final mm = months[dt.month - 1];
  final yyyy = dt.year.toString();
  final hh = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '$dd $mm $yyyy • $hh:$min';
}
