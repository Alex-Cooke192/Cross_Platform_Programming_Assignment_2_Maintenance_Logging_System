import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/task_repository.dart';
import '../models/ui_models.dart';

class CurrentTaskDetailsScreen extends StatefulWidget {
  final String taskId;

  const CurrentTaskDetailsScreen({
    super.key,
    required this.taskId,
  });

  @override
  State<CurrentTaskDetailsScreen> createState() => _CurrentTaskDetailsScreenState();
}

class _CurrentTaskDetailsScreenState extends State<CurrentTaskDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _resultController;
  late final TextEditingController _notesController;

  bool _isComplete = false;
  bool _initializedFromTask = false;

  @override
  void initState() {
    super.initState();
    _resultController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _resultController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initControllersFromTask(TaskUi task) {
    if (_initializedFromTask) return;

    final initialResult = (task.result ?? '').trim();
    _isComplete = task.completed || (initialResult.isNotEmpty && initialResult != '—');

    _resultController.text = task.result ?? '';
    _notesController.text = task.notes ?? '';

    _initializedFromTask = true;
  }

  Future<void> _save(TaskUi task) async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    final repo = context.read<TaskRepository>();

    final newResult =
        _resultController.text.trim().isEmpty ? null : _resultController.text.trim();
    final newNotes =
        _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    // Persist changes (DAO owns lastModifiedAt/version/syncStatus/completedAt rules)
    await repo.setResult(taskId: task.id, result: newResult);
    await repo.setNotes(taskId: task.id, notes: newNotes);

    // Only write completed if it actually changed (avoid extra version bumps)
    if (task.completed != _isComplete) {
      await repo.setCompleted(taskId: task.id, completed: _isComplete);
    }

    if (mounted) Navigator.of(context).pop();
  }

  void _toggleComplete(bool value) {
    setState(() {
      _isComplete = value;

      // If marking complete but no result, provide something minimally useful.
      if (_isComplete) {
        final txt = _resultController.text.trim();
        if (txt.isEmpty || txt == '—') {
          _resultController.text = 'Completed';
        }
      } else {
        // If un-completing and result is auto-filled "Completed", clear it.
        if (_resultController.text.trim() == 'Completed') {
          _resultController.clear();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<TaskRepository>();

    return StreamBuilder<TaskUi?>(
      stream: repo.watchTask(widget.taskId),
      builder: (context, snapshot) {
        final task = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting && task == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Task (Current)')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Task (Current)')),
            body: Center(child: Text('Task not found')),
          );
        }

        // Initialize controllers once from DB
        _initControllersFromTask(task);

        final code = (task.code ?? '').trim();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Task (Current)'),
            actions: [
              IconButton(
                tooltip: 'Save',
                onPressed: () => _save(task),
                icon: const Icon(Icons.save),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _save(task),
            icon: const Icon(Icons.check),
            label: const Text('Save'),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
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
                        if (code.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Code: $code'),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _isComplete ? 'Status: Complete' : 'Status: Incomplete',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            Switch(
                              value: _isComplete,
                              onChanged: _toggleComplete,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                const _SectionTitle(title: 'Result'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      controller: _resultController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'Enter the task result (e.g. OK / Fail / N/A / measurement)',
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (_isComplete) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty || t == '—') {
                            return 'Add a result or switch to incomplete.';
                          }
                        }
                        return null;
                      },
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                const _SectionTitle(title: 'Notes'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Add notes (optional).',
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 4,
                      maxLines: 10,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _save(task),
                          icon: const Icon(Icons.save),
                          label: const Text('Save changes'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          label: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
