import 'package:equatable/equatable.dart';

import '../enums/route_step_type.dart';
import 'station.dart';

/// One entry in a journey's step-by-step timeline.
class RouteStep extends Equatable {
  final RouteStepType type;
  final Station station;
  final int? lineNumber;
  final int? fromLine;
  final int? toLine;

  const RouteStep({
    required this.type,
    required this.station,
    this.lineNumber,
    this.fromLine,
    this.toLine,
  });

  RouteStep copyWith({
    RouteStepType? type,
    Station? station,
    int? lineNumber,
    int? fromLine,
    int? toLine,
  }) {
    return RouteStep(
      type: type ?? this.type,
      station: station ?? this.station,
      lineNumber: lineNumber ?? this.lineNumber,
      fromLine: fromLine ?? this.fromLine,
      toLine: toLine ?? this.toLine,
    );
  }

  @override
  List<Object?> get props => [type, station, lineNumber, fromLine, toLine];
}
