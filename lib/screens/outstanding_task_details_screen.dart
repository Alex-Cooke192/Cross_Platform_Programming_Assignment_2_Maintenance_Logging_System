import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/task_repository.dart';
import '../models/ui_models.dart';

class OutstandingTaskDetailsScreen extends StatelessWidget {
  final String taskId;

  const OutstandingTaskDetailsScreen({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    final taskRepo = context.read<TaskRepository>();

    return StreamBuilder<TaskUi?>(
      stream: taskRepo.watchById(taskId),
      builder: (context, snapshot) {
        final task = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting && task == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Task Details')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Task Details')),
            body: Center(child: Text('Task not found')),
          );
        }

        final resultText = task.result ?? '—';
        final codeText = (task.code != null && task.code!.trim().isNotEmpty)
            ? task.code!.trim()
            : '—';
        final descText =
            (task.description != null && task.description!.trim().isNotEmpty)
                ? task.description!.trim()
                : '—';
        final notesText = (task.notes != null && task.notes!.trim().isNotEmpty)
            ? task.notes!.trim()
            : '—';

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
                      children: [
                        const Text(
                          'Notes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(notesText == '—' ? 'No notes added.' : notesText),
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
