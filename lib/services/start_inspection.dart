import '../models/ui_models.dart';

class StartInspection {
  static const int maxInProgress = 3;

  InspectionUi call({
    required InspectionUi inspection,
    required List<InspectionUi> allInspections,
  }) {
    final inProgressCount =
        allInspections.where((i) => i.status == 'In Progress').length;

    if (inProgressCount >= maxInProgress) {
      throw const TooManyInProgressInspections();
    }

    if (inspection.status != 'Outstanding') {
      throw const InvalidInspectionState();
    }

    return inspection.copyWith(
      status: 'In Progress',
      openedAt: DateTime.now(),
    );
  }
}


class TooManyInProgressInspections implements Exception {
  const TooManyInProgressInspections();
}

class InvalidInspectionState implements Exception {
  const InvalidInspectionState();
}
