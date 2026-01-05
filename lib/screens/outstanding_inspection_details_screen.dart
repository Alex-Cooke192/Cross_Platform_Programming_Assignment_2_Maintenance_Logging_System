import 'package:flutter/material.dart';
import '../models/ui_models.dart';
import 'outstanding_task_details_screen.dart';

class OutstandingInspectionDetailsScreen extends StatelessWidget {
  final InspectionUi inspection;
  final List<TaskUi> tasks;

  /// How many inspections are currently in progress (to enforce max 3).
  final int inProgressCount;

  /// What should happen when the user starts this inspection.
  final VoidCallback onStartInspection;

  const OutstandingInspectionDetailsScreen({
    super.key,
    required this.inspection,
    required this.tasks,
    required this.inProgressCount,
    required this.onStartInspection,
  });

  static const int kMaxInProgressInspections = 3;

  @override
  Widget build(BuildContext context) {
    final sortedTasks = [...tasks]..sort((a, b) {
      final ac = (a.code ?? '').compareTo(b.code ?? '');
      if (ac != 0) return ac;
      return a.title.compareTo(b.title);
    });

    final canStart = inProgressCount < kMaxInProgressInspections;

    return Scaffold(
      appBar: AppBar(title: const Text('Inspection Details')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: canStart
            ? onStartInspection
            : () => _showLimitDialog(context, inProgressCount),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start inspection'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InspectionHeaderCard(inspection: inspection),

            const SizedBox(height: 16),

            const Text(
              'Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: sortedTasks.isEmpty
                  ? const Center(
                      child: Text('No tasks found for this inspection.'),
                    )
                  : ListView.separated(
                      itemCount: sortedTasks.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        return _TaskTile(
                          task: task,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OutstandingTaskDetailsScreen(task: task),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLimitDialog(BuildContext context, int count) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limit reached'),
        content: Text(
          'You already have $count inspections in progress.\n\n'
          'A maximum of $kMaxInProgressInspections can be in progress at any time. '
          'Finish one before starting another.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _InspectionHeaderCard extends StatelessWidget {
  final InspectionUi inspection;

  const _InspectionHeaderCard({required this.inspection});

  @override
  Widget build(BuildContext context) {
    final closedText = inspection.closedAt == null
        ? 'Not closed'
        : 'Closed: ${inspection.closedAt!.toLocal()}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inspection.aircraftTailNumber,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Status: ${inspection.statusLabel}'),
            const SizedBox(height: 4),
            Text('Opened by: ${inspection.openedByTechnicianUid}'),
            const SizedBox(height: 4),
            Text(
              'Opened: ${inspection.openedAt?.toLocal() ?? '—'}',
            ),
            const SizedBox(height: 4),
            Text(closedText),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskUi task;
  final VoidCallback onTap;

  const _TaskTile({
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if (task.code != null && task.code!.trim().isNotEmpty)
        task.code!.trim(),
      if (task.resultLabel != null) 'Result: ${task.resultLabel}',
      if (task.notes != null && task.notes!.trim().isNotEmpty)
        'Notes added',
    ];

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: Theme.of(context).colorScheme.surface,
      leading: Icon(
        task.completed
            ? Icons.check_circle
            : Icons.radio_button_unchecked,
      ),
      title: Text(task.title),
      subtitle:
          subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • ')),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
