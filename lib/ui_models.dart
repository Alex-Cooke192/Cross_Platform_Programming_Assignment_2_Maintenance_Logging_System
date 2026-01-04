class InspectionUi {
  final String id;
  final String aircraftTailNumber;
  final String openedByTechnicianUid;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String statusLabel;

  const InspectionUi({
    required this.id, 
    required this.aircraftTailNumber,
    required this.openedByTechnicianUid,
    required this.openedAt,
    required this.statusLabel,
    this.closedAt,
  });
}

class TaskUi {
  final String id;
  final String inspectionId;
  final String title;
  final String? code;
  final String? description;
  final bool completed;
  final String? resultLabel;
  final String? notes;

  const TaskUi({
    required this.id,
    required this.inspectionId,
    required this.title,
    this.code,
    this.description,
    required this.completed,
    this.resultLabel,
    this.notes,
  });
}
