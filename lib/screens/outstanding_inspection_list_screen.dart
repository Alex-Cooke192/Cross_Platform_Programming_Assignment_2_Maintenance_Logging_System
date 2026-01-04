import 'package:flutter/material.dart';
import '../ui_models.dart';
import 'outstanding_inspection_details_screen.dart';

class OutstandingInspectionListScreen extends StatelessWidget {
  final List<InspectionUi> inspections;
  final List<TaskUi> tasks;

  const OutstandingInspectionListScreen({
    super.key,
    required this.inspections,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspections')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: inspections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final inspection = inspections[index];
          final tasksForInspection =
              tasks.where((t) => t.inspectionId == inspection.id).toList();

          return Card(
            child: ListTile(
              title: Text(
                inspection.aircraftTailNumber,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(inspection.statusLabel),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OutstandingInspectionDetailsScreen(
                      inspection: inspection,
                      tasks: tasksForInspection,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
