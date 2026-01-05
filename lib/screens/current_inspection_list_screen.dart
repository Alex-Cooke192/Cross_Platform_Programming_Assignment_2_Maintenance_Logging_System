import 'package:flutter/material.dart';
import '../models/ui_models.dart';

const int kMaxInProgressInspections = 3;

class CurrentInspectionListScreen extends StatelessWidget {
  final List<InspectionUi> inProgressInspections;

  /// Called when the user taps an inspection in the list.
  final void Function(InspectionUi inspection) onOpenInspection;

  /// Called when user presses "Start inspection" and under the limit.
  final VoidCallback onStartNewInspection;

  const CurrentInspectionListScreen({
    super.key,
    required this.inProgressInspections,
    required this.onOpenInspection,
    required this.onStartNewInspection,
  });

  @override
  Widget build(BuildContext context) {
    final count = inProgressInspections.length;
    final canStart = count < kMaxInProgressInspections;
    final remaining = (kMaxInProgressInspections - count).clamp(0, kMaxInProgressInspections);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Inspections'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: canStart ? onStartNewInspection : () => _showLimitDialog(context, count),
        icon: const Icon(Icons.add),
        label: const Text('Start inspection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusHeader(
              count: count,
              remaining: remaining,
              canStart: canStart,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: count == 0
                  ? const _EmptyState()
                  : ListView.separated(
                      itemCount: count,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final inspection = inProgressInspections[index];
                        return _InspectionCard(
                          inspection: inspection,
                          onTap: () => onOpenInspection(inspection),
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

class _StatusHeader extends StatelessWidget {
  final int count;
  final int remaining;
  final bool canStart;

  const _StatusHeader({
    required this.count,
    required this.remaining,
    required this.canStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 28,
              color: canStart ? theme.colorScheme.primary : theme.colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count / $kMaxInProgressInspections in progress',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    canStart
                        ? '$remaining slot${remaining == 1 ? '' : 's'} remaining'
                        : 'Finish one to start another',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InspectionCard extends StatelessWidget {
  final InspectionUi inspection;
  final VoidCallback onTap;

  const _InspectionCard({
    required this.inspection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final started = inspection.openedAt == null
      ? '—'
      : _formatDateTime(inspection.openedAt!);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.assignment_outlined),
        title: Text(
          inspection.id,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [      
            const SizedBox(height: 2),
            Text('Started: $started'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  static String _formatDateTime(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'No inspections in progress',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Start a new inspection to see it here.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
