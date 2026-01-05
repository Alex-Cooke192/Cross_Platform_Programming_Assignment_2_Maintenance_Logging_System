import 'package:flutter/foundation.dart';

import '../models/ui_models.dart';
import 'start_inspection.dart';

class InspectionService {
  final StartInspection _startInspection;

  InspectionService(this._startInspection);

  static const int maxInProgress = 3;

  /// Convenience: count how many inspections are currently in progress.
  int inProgressCount(List<InspectionUi> allInspections) {
    return allInspections.where((i) => i.statusLabel == 'In Progress').length;
  }

  /// Returns true if another inspection can be started right now.
  bool canStartAnother(List<InspectionUi> allInspections) {
    return inProgressCount(allInspections) < maxInProgress;
  }

  /// Starts [inspection] and returns a NEW updated inspections list.
  /// Throws:
  /// - [TooManyInProgressInspections]
  /// - [InvalidInspectionState]
  List<InspectionUi> startInspection({
    required InspectionUi inspection,
    required List<InspectionUi> allInspections,
  }) {
    final updatedInspection = _startInspection(
      inspection: inspection,
      allInspections: allInspections,
    );

    return allInspections
        .map((i) => i.id == updatedInspection.id ? updatedInspection : i)
        .toList();
  }

  /// Optional helper: produces a `VoidCallback` you can pass directly to a button/screen.
  /// UI supplies two hooks:
  /// - [getAll] to provide the latest list at the moment the user taps
  /// - [applyUpdated] to store the returned updated list wherever your state lives
  VoidCallback buildStartInspectionCallback({
    required InspectionUi inspection,
    required List<InspectionUi> Function() getAll,
    required void Function(List<InspectionUi> updated) applyUpdated,
  }) {
    return () {
      final all = getAll();
      final updated = startInspection(
        inspection: inspection,
        allInspections: all,
      );
      applyUpdated(updated);
    };
  }
}

