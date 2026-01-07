import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:maintenance_logging_system/services/inspection_service.dart';
import 'package:maintenance_logging_system/services/start_inspection.dart';

import '../data/repositories/inspection_repository.dart';
import '../models/ui_models.dart';
import 'outstanding_inspection_details_screen.dart';

class OutstandingInspectionListScreen extends StatefulWidget {
  const OutstandingInspectionListScreen({super.key});

  @override
  State<OutstandingInspectionListScreen> createState() =>
      _OutstandingInspectionListScreenState();
}

class _OutstandingInspectionListScreenState
    extends State<OutstandingInspectionListScreen> {
  late final InspectionService _inspectionService;

  @override
  void initState() {
    super.initState();
    _inspectionService = InspectionService(StartInspection());
  }

  @override
  Widget build(BuildContext context) {
    final inspectionRepo = context.read<InspectionRepository>();

    return StreamBuilder<List<InspectionUi>>(
      stream: inspectionRepo.watchOutstandingInspections(),
      initialData: const [],
      builder: (context, outstandingSnap) {
        final inspections = outstandingSnap.data ?? const [];

        return StreamBuilder<int>(
          // requires your repo count stream (Option A)
          stream: inspectionRepo.watchInProgressCount(),
          initialData: 0,
          builder: (context, inProgressCountSnap) {
            final inProgressCount = inProgressCountSnap.data ?? 0;

            return Scaffold(
              appBar: AppBar(title: const Text('Inspections')),
              body: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: inspections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final inspection = inspections[index];

                  // Load tasks for this inspection from DB via repo
                  return StreamBuilder<List<TaskUi>>(
                    stream: inspectionRepo.watchTasksForInspection(inspection.id),
                    initialData: const [],
                    builder: (context, tasksSnap) {
                      final tasksForInspection = tasksSnap.data ?? const [];

                      return Card(
                        child: ListTile(
                          title: Text(
                            inspection.aircraftTailNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(inspection.status),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OutstandingInspectionDetailsScreen(
                                  inspection: inspection,
                                  tasks: tasksForInspection,
                                  inProgressCount: inProgressCount,

                                  // IMPORTANT: with DB-backed state you generally
                                  // want this callback to write to DB (repo.startInspection),
                                  // not mutate an in-memory list.
                                  //
                                  // If your details screen expects a VoidCallback:
                                  onStartInspection: () async {
                                    // You need technicianUid from your auth/session.
                                    // Replace this with the real value.
                                    const technicianUid = 'TECHNICIAN_UID_TODO';

                                    await inspectionRepo.startInspection(
                                      inspectionId: inspection.id,
                                      technicianUid: technicianUid,
                                    );

                                    // No setState needed. Streams update automatically.
                                    if (context.mounted) Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
