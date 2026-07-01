import '../../../../shared/models/station.dart';

/// Raw graph data as loaded from `metro.db`, before it's handed to
/// [PathfindingEngine].
class MetroGraphData {
  final List<Station> stations;
  final Map<String, List<String>> adjacency;

  const MetroGraphData({required this.stations, required this.adjacency});
}
