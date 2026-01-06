import 'package:flutter/material.dart';
import '../models/ui_models.dart';

class OutstandingTaskDetailsScreen extends StatelessWidget {
  final TaskUi task;

  const OutstandingTaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final resultText = task.result ?? '—';
    final codeText =
        (task.code != null && task.code!.trim().isNotEmpty) ? task.code!.trim() : '—';
    final descText =
        (task.description != null && task.description!.trim().isNotEmpty)
            ? task.description!.trim()
            : '—';
    final notesText =
        (task.notes != null && task.notes!.trim().isNotEmpty) ? task.notes!.trim() : '—';

    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _ReadOnlyRow(label: 'Code', value: codeText),
                    const SizedBox(height: 8),
                    _ReadOnlyRow(label: 'Description', value: descText),
                    const SizedBox(height: 8),
                    _ReadOnlyRow(label: 'Result', value: resultText),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Text('Status'),
                        const Spacer(),
                        Text(
                          'Outstanding',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Notes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('No notes added.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }
}
