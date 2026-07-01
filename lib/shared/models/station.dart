import 'package:equatable/equatable.dart';

import '../../core/constants/db_constants.dart';

/// A single metro station, including the metro line(s) it belongs to and
/// every amenity flag from the `stations` table.
class Station extends Equatable {
  final String id;
  final String nameEn;
  final String nameFa;
  final String? address;
  final double latitude;
  final double longitude;

  /// Metro line numbers this station sits on (a station can serve more
  /// than one line — that's exactly where line changes happen).
  final List<int> lines;

  // ── Amenities ──────────────────────────────────────────────────────────
  final bool disabled;
  final bool wc;
  final bool coffeeShop;
  final bool groceryStore;
  final bool fastFood;
  final bool atm;
  final bool elevator;
  final bool bicycleParking;
  final bool waterCooler;
  final bool cleanFood;
  final bool blindPath;
  final bool fireSuppressionSystem;
  final bool fireExtinguisher;
  final bool metroPolice;
  final bool creditTicketSales;
  final bool waitingChair;
  final bool camera;
  final bool trashCan;
  final bool smoking;
  final bool petsAllowed;
  final bool freeWifi;
  final bool prayerRoom;

  const Station({
    required this.id,
    required this.nameEn,
    required this.nameFa,
    required this.latitude,
    required this.longitude,
    this.address,
    this.lines = const [],
    this.disabled = false,
    this.wc = false,
    this.coffeeShop = false,
    this.groceryStore = false,
    this.fastFood = false,
    this.atm = false,
    this.elevator = false,
    this.bicycleParking = false,
    this.waterCooler = false,
    this.cleanFood = false,
    this.blindPath = false,
    this.fireSuppressionSystem = false,
    this.fireExtinguisher = false,
    this.metroPolice = false,
    this.creditTicketSales = false,
    this.waitingChair = false,
    this.camera = false,
    this.trashCan = false,
    this.smoking = false,
    this.petsAllowed = false,
    this.freeWifi = false,
    this.prayerRoom = false,
  });

  /// The label shown throughout the (Farsi-first) UI. Falls back to the
  /// English name if, for some reason, no Farsi name was provided.
  String get displayName => nameFa.isNotEmpty ? nameFa : nameEn;

  /// Builds a [Station] from a joined `stations` ⨝ `station_lines` row,
  /// where `lines` is the comma-separated string produced by
  /// `GROUP_CONCAT(sl.line)`.
  factory Station.fromRow(Map<String, Object?> row) {
    bool flag(String key) => (row[key] as int?) == 1;

    final linesRaw = row[DbConstants.colLinesAggregate] as String? ?? '';
    final lines = linesRaw.isEmpty
        ? const <int>[]
        : linesRaw
            .split(',')
            .map(int.tryParse)
            .whereType<int>()
            .toList(growable: false);

    return Station(
      id: row[DbConstants.colId] as String,
      nameEn: row[DbConstants.colNameEn] as String? ?? '',
      nameFa: row[DbConstants.colNameFa] as String? ?? '',
      address: row[DbConstants.colAddress] as String?,
      latitude: (row[DbConstants.colLatitude] as num?)?.toDouble() ?? 0,
      longitude: (row[DbConstants.colLongitude] as num?)?.toDouble() ?? 0,
      lines: lines,
      disabled: flag(DbConstants.colDisabled),
      wc: flag(DbConstants.colWc),
      coffeeShop: flag(DbConstants.colCoffeeShop),
      groceryStore: flag(DbConstants.colGroceryStore),
      fastFood: flag(DbConstants.colFastFood),
      atm: flag(DbConstants.colAtm),
      elevator: flag(DbConstants.colElevator),
      bicycleParking: flag(DbConstants.colBicycleParking),
      waterCooler: flag(DbConstants.colWaterCooler),
      cleanFood: flag(DbConstants.colCleanFood),
      blindPath: flag(DbConstants.colBlindPath),
      fireSuppressionSystem: flag(DbConstants.colFireSuppressionSystem),
      fireExtinguisher: flag(DbConstants.colFireExtinguisher),
      metroPolice: flag(DbConstants.colMetroPolice),
      creditTicketSales: flag(DbConstants.colCreditTicketSales),
      waitingChair: flag(DbConstants.colWaitingChair),
      camera: flag(DbConstants.colCamera),
      trashCan: flag(DbConstants.colTrashCan),
      smoking: flag(DbConstants.colSmoking),
      petsAllowed: flag(DbConstants.colPetsAllowed),
      freeWifi: flag(DbConstants.colFreeWifi),
      prayerRoom: flag(DbConstants.colPrayerRoom),
    );
  }

  @override
  List<Object?> get props => [id];
}
