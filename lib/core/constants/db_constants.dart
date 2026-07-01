/// Table & column names for `metro.db`, kept in one place so the SQL in
/// [MetroLocalDataSource] reads cleanly and survives schema tweaks.
abstract final class DbConstants {
  static const String dbFileName = 'metro.db';

  // stations table
  static const String tableStations = 'stations';
  static const String colId = 'id';
  static const String colNameEn = 'name_en';
  static const String colNameFa = 'name_fa';
  static const String colAddress = 'address';
  static const String colLatitude = 'latitude';
  static const String colLongitude = 'longitude';
  static const String colDisabled = 'disabled';
  static const String colWc = 'wc';
  static const String colCoffeeShop = 'coffee_shop';
  static const String colGroceryStore = 'grocery_store';
  static const String colFastFood = 'fast_food';
  static const String colAtm = 'atm';
  static const String colElevator = 'elevator';
  static const String colBicycleParking = 'bicycle_parking';
  static const String colWaterCooler = 'water_cooler';
  static const String colCleanFood = 'clean_food';
  static const String colBlindPath = 'blind_path';
  static const String colFireSuppressionSystem = 'fire_suppression_system';
  static const String colFireExtinguisher = 'fire_extinguisher';
  static const String colMetroPolice = 'metro_police';
  static const String colCreditTicketSales = 'credit_ticket_sales';
  static const String colWaitingChair = 'waiting_chair';
  static const String colCamera = 'camera';
  static const String colTrashCan = 'trash_can';
  static const String colSmoking = 'smoking';
  static const String colPetsAllowed = 'pets_allowed';
  static const String colFreeWifi = 'free_wifi';
  static const String colPrayerRoom = 'prayer_room';

  // station_lines table (one row per station ↔ metro-line membership)
  static const String tableStationLines = 'station_lines';
  static const String colStationId = 'station_id';
  static const String colLine = 'line';

  // connections table (undirected edges between adjacent stations)
  static const String tableConnections = 'connections';
  static const String colFromId = 'from_id';
  static const String colToId = 'to_id';

  /// Computed column produced by `GROUP_CONCAT(sl.line)` when joining
  /// stations with their lines.
  static const String colLinesAggregate = 'lines';
}
