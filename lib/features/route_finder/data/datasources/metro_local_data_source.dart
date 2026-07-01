import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/models/station.dart';
import 'metro_graph_data.dart';

/// Reads `metro.db` and assembles the full stations + adjacency graph in
/// two queries. Everything downstream (pathfinding) then operates purely
/// in memory, so a search never touches SQLite again after the first load.
class MetroLocalDataSource {
  final AppDatabase _appDatabase;

  MetroLocalDataSource(this._appDatabase);

  Future<MetroGraphData> loadGraph() async {
    final db = await _appDatabase.database;

    final stationRows = await db.rawQuery('''
      SELECT s.*, GROUP_CONCAT(sl.${DbConstants.colLine}) AS ${DbConstants.colLinesAggregate}
      FROM ${DbConstants.tableStations} s
      LEFT JOIN ${DbConstants.tableStationLines} sl
        ON sl.${DbConstants.colStationId} = s.${DbConstants.colId}
      GROUP BY s.${DbConstants.colId}
    ''');

    final stations = stationRows.map(Station.fromRow).toList();

    final connectionRows = await db.rawQuery(
      'SELECT ${DbConstants.colFromId}, ${DbConstants.colToId} '
      'FROM ${DbConstants.tableConnections}',
    );

    final adjacency = <String, List<String>>{
      for (final station in stations) station.id: <String>[],
    };

    for (final row in connectionRows) {
      final from = row[DbConstants.colFromId] as String;
      final to = row[DbConstants.colToId] as String;
      adjacency.putIfAbsent(from, () => []).add(to);
      adjacency.putIfAbsent(to, () => []).add(from);
    }

    return MetroGraphData(stations: stations, adjacency: adjacency);
  }
}
