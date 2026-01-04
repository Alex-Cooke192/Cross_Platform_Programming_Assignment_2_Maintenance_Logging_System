import '../ui_models.dart';

class MockData {
  static final inspections = <InspectionUi>[
    InspectionUi(
      id: 'insp-1',
      aircraftTailNumber: 'G-ABCD',
      openedByTechnicianUid: 'tech01',
      openedAt: DateTime.now().subtract(const Duration(hours: 3)),
      statusLabel: 'In Progress',
    ),
    InspectionUi(
      id: 'insp-2',
      aircraftTailNumber: 'G-EFGH',
      openedByTechnicianUid: 'tech02',
      openedAt: DateTime.now().subtract(const Duration(days: 1)),
      statusLabel: 'Open',
    ),
  ];

  static final tasks = <TaskUi>[
    TaskUi(
      id: 'task-1',
      inspectionId: 'insp-1',
      title: 'Check tire pressure',
      code: 'T01',
      completed: true,
      resultLabel: 'PASS',
    ),
    TaskUi(
      id: 'task-2',
      inspectionId: 'insp-1',
      title: 'Inspect wing flaps',
      code: 'W12',
      completed: false,
    ),
    TaskUi(
      id: 'task-3',
      inspectionId: 'insp-2',
      title: 'Check oil level',
      code: 'O03',
      completed: false,
    ),
  ];
}
