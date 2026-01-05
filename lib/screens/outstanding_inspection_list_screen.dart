import 'package:flutter/material.dart';
import 'package:maintenance_logging_system/services/inspection_service.dart';
import '../ui_models.dart';
import 'outstanding_inspection_details_screen.dart';
import 'package:maintenance_logging_system/services/start_inspection.dart';

class OutstandingInspectionListScreen extends StatefulWidget {
  final List<InspectionUi> inspections;
  final List<TaskUi> tasks;

  const OutstandingInspectionListScreen({
    super.key,
    required this.inspections,
    required this.tasks,
  });

  @override
  State<OutstandingInspectionListScreen> createState() =>
      _OutstandingInspectionListScreenState();
}

class _OutstandingInspectionListScreenState
    extends State<OutstandingInspectionListScreen> {
  late List<InspectionUi> _inspections;

  late final InspectionService _inspectionService;

  @override
  void initState() {
    super.initState();
    _inspections = widget.inspections;

    // Service instance (not static)
    _inspectionService = InspectionService(StartInspection());
  }

  @override
  Widget build(BuildContext context) {
    // Find the number of in progress inspections
    final inProgressCount =
        _inspectionService.inProgressCount(_inspections); // or compute here

    return Scaffold(
      appBar: AppBar(title: const Text('Inspections')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _inspections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final inspection = _inspections[index];
          final tasksForInspection =
              widget.tasks.where((t) => t.inspectionId == inspection.id).toList();

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
                      inProgressCount: inProgressCount,
                      onStartInspection: _inspectionService.buildStartInspectionCallback(
                        inspection: inspection,
                        getAll: () => _inspections,
                        applyUpdated: (updated) {
                          setState(() {
                            _inspections = updated;
                          });
                          Navigator.pop(context);
                        },
                      ),
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
