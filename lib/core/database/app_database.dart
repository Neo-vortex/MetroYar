import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/asset_paths.dart';
import '../constants/db_constants.dart';

/// Opens (and, on first run, installs) the read-only `metro.db` asset that
/// ships with the app.
///
/// sqflite can't query a database straight out of the asset bundle, so the
/// very first launch copies the bytes to the app's documents directory.
/// On every later launch we compare file sizes and re-copy automatically if
/// the bundled asset changed — handy after an app update ships a refreshed
/// station/line dataset, without needing a manual cache-clear.
class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null && existing.isOpen) return existing;
    final opened = await _open();
    _database = opened;
    return opened;
  }

  Future<Database> _open() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(directory.path, DbConstants.dbFileName);
    final dbFile = File(dbPath);

    final assetBytes =
        (await rootBundle.load(AssetPaths.metroDatabase)).buffer.asUint8List();

    final needsCopy = !dbFile.existsSync() ||
        (await dbFile.length()) != assetBytes.length;

    if (needsCopy) {
      await dbFile.create(recursive: true);
      await dbFile.writeAsBytes(assetBytes, flush: true);
    }

    return openDatabase(dbPath, readOnly: true);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
    _database = null;
  }
}
