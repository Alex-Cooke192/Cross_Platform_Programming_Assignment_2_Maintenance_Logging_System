import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/inspection_repository.dart';
import '../models/ui_models.dart';
import 'current_task_details_screen.dart';

class CurrentInspectionDetailsScreen extends StatelessWidget {
  final String inspectionId;

  const CurrentInspectionDetailsScreen({
    super.key,
    required this.inspectionId,
  });

  @override
  Widget build(BuildContext context) {
    final inspectionRepo = context.read<InspectionRepository>();

    return StreamBuilder<InspectionUi?>(
      stream: inspectionRepo.watchInspection(inspectionId),
      builder: (context, inspectionSnap) {
        final inspection = inspectionSnap.data;

        if (inspectionSnap.connectionState == ConnectionState.waiting &&
            inspection == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Current Inspection')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (inspection == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Current Inspection')),
            body: Center(child: Text('Inspection not found')),
          );
        }

        return StreamBuilder<List<TaskUi>>(
          stream: inspectionRepo.watchTasksForInspection(inspection.id),
          initialData: const [],
          builder: (context, tasksSnap) {
            final tasks = tasksSnap.data ?? const [];

            final sortedTasks = [...tasks]..sort((a, b) {
              final ac = (a.code ?? '').compareTo(b.code ?? '');
              if (ac != 0) return ac;
              return a.title.compareTo(b.title);
            });

            final completedCount = sortedTasks.where(_isTaskComplete).length;
            final totalCount = sortedTasks.length;
            final progress = totalCount == 0 ? 0.0 : (completedCount / totalCount);

            return Scaffold(
              appBar: AppBar(
                title: const Text('Current Inspection'),
                actions: const [
                  Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Center(child: _StatusChip(label: 'IN PROGRESS')),
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _HeaderCard(
                    inspection: inspection,
                    completedCount: completedCount,
                    totalCount: totalCount,
                    progress: progress,
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(
                    title: 'Tasks',
                    trailing: Text(
                      totalCount == 0 ? '—' : '$completedCount / $totalCount',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (sortedTasks.isEmpty)
                    const _EmptyStateCard(
                      title: 'No tasks found',
                      message: 'This inspection has no tasks to complete.',
                    )
                  else
                    ...sortedTasks.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TaskTile(
                          task: t,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CurrentTaskDetailsScreen(
                                  taskId: t.id, // ✅ DI-compatible task details
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  _ActionsCard(
                    canComplete: totalCount > 0 && completedCount == totalCount,
                    onMarkComplete: () => _markInspectionComplete(context, inspection),
                    onPauseInspection: () => Navigator.of(context).pop(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _isTaskComplete(TaskUi task) {
    // Prefer DB field if you have it:
    if (task.completed) return true;

    final label = (task.result ?? '').trim();
    return label.isNotEmpty && label != '—';
  }

  Future<void> _markInspectionComplete(BuildContext context, InspectionUi inspection) async {
    final inspectionRepo = context.read<InspectionRepository>();

    // TODO: replace with your real logged-in technician uid
    const technicianUid = 'TECHNICIAN_UID_TODO';

    await inspectionRepo.completeInspection(
      inspectionId: inspection.id,
      technicianUid: technicianUid,
    );

    if (context.mounted) Navigator.of(context).pop();
  }
}

class _HeaderCard extends StatelessWidget {
  final InspectionUi inspection;
  final int completedCount;
  final int totalCount;
  final double progress;

  const _HeaderCard({
    required this.inspection,
    required this.completedCount,
    required this.totalCount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final inspectionId = inspection.id;

    final subtitleParts = <String>[
      _safe(inspection.openedByTechnicianUid),
      _formatStarted(inspection.openedAt),
    ].where((s) => s != '—').toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inspectionId.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitleParts.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(subtitleParts.join(' • ')),
            ],
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  totalCount == 0 ? 'Progress —' : 'Progress $completedCount / $totalCount',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text('${(progress * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: progress),
            ),
            const SizedBox(height: 14),
            _InfoGrid(inspection: inspection),
          ],
        ),
      ),
    );
  }

  static String _safe(String? v) => (v == null || v.trim().isEmpty) ? '—' : v.trim();

  static String _formatStarted(DateTime? dt) {
    if (dt == null) return '—';
    String two(int v) => v.toString().padLeft(2, '0');
    return 'Started: ${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _InfoGrid extends StatelessWidget {
  final InspectionUi inspection;

  const _InfoGrid({required this.inspection});

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRow>[
      _InfoRow(label: 'Inspector', value: _safe(inspection.openedByTechnicianUid)),
      _InfoRow(label: 'Opened at', value: _formatDateTime(inspection.openedAt)),
    ].where((r) => r.value != '—').toList();

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const Divider(height: 1),
        const SizedBox(height: 12),
        ...rows.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    r.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Expanded(child: Text(r.value)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _safe(String? v) => (v == null || v.trim().isEmpty) ? '—' : v.trim();

  static String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _InfoRow {
  final String label;
  final String value;

  _InfoRow({required this.label, required this.value});
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
    final code = (task.code ?? '').trim();
    final result = (task.result ?? '—').trim();
    final isComplete = task.completed || (result.isNotEmpty && result != '—');

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(isComplete ? Icons.check_circle : Icons.radio_button_unchecked),
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (code.isNotEmpty) Text('Code: $code'),
            Text('Result: $result'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  final bool canComplete;
  final VoidCallback onMarkComplete;
  final VoidCallback? onPauseInspection;

  const _ActionsCard({
    required this.canComplete,
    required this.onMarkComplete,
    required this.onPauseInspection,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: canComplete ? onMarkComplete : null,
              icon: const Icon(Icons.done_all),
              label: const Text('Mark inspection complete'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onPauseInspection ?? () => Navigator.of(context).pop(),
              icon: const Icon(Icons.pause_circle_outline),
              label: Text(onPauseInspection == null ? 'Back to list' : 'Pause inspection'),
            ),
            if (!canComplete) ...[
              const SizedBox(height: 10),
              Text(
                'Complete all tasks to mark this inspection as complete.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyStateCard({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(message),
          ],
        ),
      ),
    );
  }
}
