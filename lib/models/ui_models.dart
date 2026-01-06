

class InspectionUi {
  final String id; 
  final String? serverId;
  final String aircraftTailNumber;
  final String openedByTechnicianUid;

  final DateTime? openedAt;

  final DateTime? closedAt;

  final String status;

  final bool synced;

  InspectionUi({
    required this.id,
    this.serverId,
    required this.aircraftTailNumber,
    required this.openedByTechnicianUid,
    this.openedAt,
    this.closedAt,
    required this.status,
    required this.synced,
  });

  InspectionUi copyWith({
    String? id,
    String? serverId,
    String? aircraftTailNumber,
    String? openedByTechnicianUid,
    DateTime? openedAt,
    DateTime? closedAt,
    String? status,
    bool? synced,
  }) {
    return InspectionUi(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      aircraftTailNumber: aircraftTailNumber ?? this.aircraftTailNumber,
      openedByTechnicianUid: openedByTechnicianUid ?? this.openedByTechnicianUid,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      status: status ?? this.status,
      synced: synced ?? this.synced,
    );
  }
}

class TaskUi {
  final String id; 
  final String? serverId; 
  final String inspectionId; 
  final String title;
  final String? code;
  final String? description;

  final String? result;

  final String? notes;

  final bool completed;

  final DateTime? completedAt;

  final DateTime lastModifiedAt;
  final bool synced;

  TaskUi({
    required this.id,
    this.serverId,
    required this.inspectionId,
    required this.title,
    this.code,
    this.description,
    this.result,
    this.notes,
    required this.completed,
    this.completedAt,
    required this.lastModifiedAt,
    required this.synced,
  });

  TaskUi copyWith({
    String? id,
    String? serverId,
    String? inspectionId,
    String? title,
    String? code,
    String? description,
    String? result,
    String? notes,
    bool? completed,
    DateTime? completedAt,
    DateTime? lastModifiedAt,
    bool? synced,
  }) {
    return TaskUi(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      inspectionId: inspectionId ?? this.inspectionId,
      title: title ?? this.title,
      code: code ?? this.code,
      description: description ?? this.description,
      result: result ?? this.result,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      synced: synced ?? this.synced,
    );
  }
}

