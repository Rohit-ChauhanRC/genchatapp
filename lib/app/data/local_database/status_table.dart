
import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/status_model.dart';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class StatusTable {
  final tableName = statusDb;

  Future<void> createTable(Database database) async {
    print("Creating Status Table...");

    await database.execute("""
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY,
      userId INTEGER,
      isAsset INTEGER,
      statusText TEXT,
      statusAssetType TEXT,
      isDeleted INTEGER,
      createdAt TEXT,
      assetUrl TEXT,
      localPath TEXT         -- ⭐ IMPORTANT FOR OFFLINE MODE
    );
    """);

    print("✅ Status table created (or already exists)");
  }

  // Add missing onUpgrade to add localPath column
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Check columns
      final res = await db.rawQuery("PRAGMA table_info($tableName);");
      final columns = res.map((e) => e['name']).toList();

      if (!columns.contains("localPath")) {
        await db.execute("ALTER TABLE $tableName ADD COLUMN localPath TEXT;");
        print("🆕 Added localPath column to $tableName");
      }
    }
  }

  Future<void> saveAllStatuses(List<Statusmodel> list) async {
    final db = await DataBaseService().database;

    print("💾 Saving ${list.length} statuses into SQLite...");

    // (Optional) Clear old data
    // await db.delete(tableName);

    final batch = db.batch();

    for (var s in list) {
      print(" Inserting Status -> id=${s.id}, userId=${s.userId}, url=${s.assetUrl}, local=${s.localPath}");

      batch.insert(
        tableName,
        {
          "id": s.id,
          "userId": s.userId,
          "isAsset": s.isAsset,
          "statusText": s.statusText,
          "assetUrl": s.assetUrl,
          "localPath": s.localPath,
          "statusAssetType": s.statusAssetType,
          "createdAt": s.createdAt,
          "isDeleted": s.isDeleted,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print("All statuses inserted successfully!");
  }

  Future<List<Statusmodel>> getAllStatuses() async {
    final db = await DataBaseService().database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: "createdAt ASC",
    );

    return maps.map((e) => Statusmodel.fromJson(e)).toList();
  }
  Future<void> deleteTable() async {
    final db = await DataBaseService().database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
    await createTable(db);
  }
}
