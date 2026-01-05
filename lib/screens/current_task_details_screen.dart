import 'package:flutter/material.dart';
import '../models/ui_models.dart';

/// Task details for an in-progress (current) inspection.
/// This screen allows editing (notes/result) and completing the task.
///
/// Assumptions about TaskUi (adjust field usage if yours differs):
/// - title: String
/// - code: String?
/// - resultLabel: String?   (we'll treat as the "result/answer" for now)
/// - notes: String?         (if you don't have this, you can store notes elsewhere and map it in/out)
///
/// This screen does NOT persist anything itself; you provide callbacks.
class CurrentTaskDetailsScreen extends StatefulWidget {
  final TaskUi task;

  /// Called whenever the user saves changes (notes/result/complete).
  /// Return the updated task to the parent/store.
  final ValueChanged<TaskUi> onSave;

  /// Optional: called if user explicitly marks complete (in addition to onSave).
  final ValueChanged<TaskUi>? onMarkComplete;

  const CurrentTaskDetailsScreen({
    super.key,
    required this.task,
    required this.onSave,
    this.onMarkComplete,
  });

  @override
  State<CurrentTaskDetailsScreen> createState() => _CurrentTaskDetailsScreenState();
}

class _CurrentTaskDetailsScreenState extends State<CurrentTaskDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _resultController;
  late final TextEditingController _notesController;

  bool _isComplete = false;

  @override
  void initState() {
    super.initState();

    // Treat "resultLabel" being set as completion (matches your earlier logic).
    final initialResult = (widget.task.resultLabel ?? '').trim();
    _isComplete = initialResult.isNotEmpty && initialResult != '—';

    _resultController = TextEditingController(text: widget.task.resultLabel ?? '');
    _notesController = TextEditingController(text: _readNotes(widget.task));
  }

  @override
  void dispose() {
    _resultController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    final updated = _copyTask(
      widget.task,
      resultLabel: _resultController.text.trim().isEmpty ? null : _resultController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isComplete: _isComplete,
    );

    widget.onSave(updated);
    if (_isComplete) widget.onMarkComplete?.call(updated);

    if (mounted) Navigator.of(context).pop();
  }

  void _toggleComplete(bool value) {
    setState(() {
      _isComplete = value;

      // If marking complete but no result, put something minimally useful.
      // Remove this if you want "complete" to be independent of result.
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
    final code = (widget.task.code ?? '').trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task (Current)'),
        actions: [
          IconButton(
            tooltip: 'Save',
            onPressed: _save,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
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
                      widget.task.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            _SectionTitle(title: 'Result'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextFormField(
                  controller: _resultController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter the task result (e.g. OK / Fail / N/A / measurement)',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    // If complete, encourage a result (optional, but usually useful).
                    if (_isComplete) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty || t == '—') return 'Add a result or switch to incomplete.';
                    }
                    return null;
                  },
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
            ),

            const SizedBox(height: 14),

            _SectionTitle(title: 'Notes'),
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
                      onPressed: _save,
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
  }

  // ---- Helpers: you can replace these with your real model logic ----

  String _readNotes(TaskUi task) {
    // If your TaskUi already has notes, use it.
    // If not, return '' and store notes elsewhere via onSave.
    try {
      final dynamic dyn = task;
      final v = dyn.notes;
      if (v is String) return v;
    } catch (_) {}
    return '';
  }

  TaskUi _copyTask(
    TaskUi task, {
    String? resultLabel,
    String? notes,
    required bool isComplete,
  }) {
    // If your TaskUi is immutable with copyWith, use it:
    // return task.copyWith(resultLabel: ..., notes: ...);

    // Fallback: best-effort dynamic copyWith.
    // You should replace this with your actual model implementation.
    try {
      final dynamic dyn = task;
      if (dyn.copyWith is Function) {
        return dyn.copyWith(
          resultLabel: resultLabel,
          notes: notes,
          // If your model has isComplete / status, map it here:
          isComplete: isComplete,
        ) as TaskUi;
      }
    } catch (_) {}

    // If no copyWith exists, you *must* update your TaskUi model or handle updates in parent.
    // We return the original task to avoid crashing, but nothing will persist.
    return task;
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
