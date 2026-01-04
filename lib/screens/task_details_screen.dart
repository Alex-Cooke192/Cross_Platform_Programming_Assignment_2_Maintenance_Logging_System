import 'package:flutter/material.dart';
import '../ui_models.dart';


class TaskDetailsScreen extends StatelessWidget {
  final TaskUi task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final resultText = task.resultLabel ?? '—';

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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (task.code != null && task.code!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Code: ${task.code}'),
                    ],
                    if (task.description != null && task.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(task.description!),
                    ],
                    const SizedBox(height: 12),
                    Text('Result: $resultText'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Completed'),
                        const Spacer(),
                        Icon(task.completed ? Icons.check_circle : Icons.radio_button_unchecked),
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
                    Text(task.notes?.trim().isNotEmpty == true ? task.notes! : 'No notes added.'),
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
