class InspectionUi {
  final String id;
  final String aircraftTailNumber;
  final String openedByTechnicianUid;
  DateTime? openedAt;
  DateTime? closedAt;
  String statusLabel;

  InspectionUi({
    required this.id, 
    required this.aircraftTailNumber,
    required this.openedByTechnicianUid,
    this.openedAt,
    required this.statusLabel, 
    this.closedAt,
  });

  InspectionUi copyWith({
    String? id,
    String? aircraftTailNumber,
    String? statusLabel,
    String? openedByTechnicianUid,
    DateTime? openedAt,
    DateTime? closedAt,
    }) {
    return InspectionUi(
      id: id ?? this.id,
      aircraftTailNumber: aircraftTailNumber ?? this.aircraftTailNumber,
      statusLabel: statusLabel ?? this.statusLabel,
      openedByTechnicianUid: openedByTechnicianUid ?? this.openedByTechnicianUid,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }
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
