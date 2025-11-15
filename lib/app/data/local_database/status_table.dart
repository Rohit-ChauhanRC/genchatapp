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
      assetUrl TEXT
    );
  """);

    print("✅ Status table created (or already exists)");
  }

  Future<int> create(Statusmodel status) async {
    final db = await DataBaseService().database;
    return await db.insert(
      tableName,
      status.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Statusmodel>> fetchAll() async {
    final db = await DataBaseService().database;
    final result = await db.query(tableName);
    return result.map((e) => Statusmodel.fromJson(e)).toList();
  }

  Future<Statusmodel?> getUserById(int userId) async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );

 

     if (result.isNotEmpty) {

      return Statusmodel.fromJson(result.first);
    } else {
      return null;
    }
  }

  Future<void> insertStatus({
    required int id,

    required int userId,
    required int isAsset,
    required int isDeleted,
    required String? statusText,
    required String? statusAssetUrl,
  }) async {
    final db = await DataBaseService().database;

    final status = {
      'id': id,
      'userId': userId,
      'isAsset': isAsset,
      'isDeleted': isDeleted,
      'statusText': statusText ?? "",
      'statusAssetUrl': statusAssetUrl,
    };

    await db.insert(
      tableName,
      status,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  void onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      db.execute("ALTER TABLE $tableName ADD COLUMN assetUrl TEXT;");
    }
  }

  Future<void> deleteTable() async {
    final db = await DataBaseService().database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
    await createTable(db);
  }


  // Future<void> createBulk(List<Statusmodel> users) async {
  //   final db = await DataBaseService().database;

  //   // 1. Fetch all existing contacts with userId and localName
  //   final existing = await db.query(
  //     tableName,
  //     columns: ['userId', 'localName'],
  //   );
  //   final existingMap = {
  //     for (var row in existing)
  //       row['userId'].toString(): (row['localName'] ?? '') as String,
  //   };

  //   // 2. Get new userIds from the incoming contacts list
  //   final newUserIds = users.map((u) => u.userId.toString()).toSet();

  //   final batch = db.batch();

  //   // List to keep track of changes for logging
  //   final clearedLocalNames = <String>[];
  //   final insertedUsers = <String>[];

  //   // 3. Identify userIds that were in DB earlier but not in new list → deleted from phone
  //   for (final oldUserId in existingMap.keys) {
  //     if (!newUserIds.contains(oldUserId)) {
  //       // This contact was removed from phone — clear only localName
  //       batch.update(
  //         tableName,
  //         {'localName': ''},
  //         where: 'userId = ?',
  //         whereArgs: [int.parse(oldUserId)],
  //       );
  //       clearedLocalNames.add(oldUserId);
  //     }
  //   }

  //   // 4. Insert/update the current contacts from API+phone sync
  //   for (final user in users) {
  //     batch.insert(
  //       tableName,
  //       user.toJson(),
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //     insertedUsers.add(user.userId.toString());
  //   }

  //   await batch.commit(noResult: true);

  //   // 5. Logging
  //   if (clearedLocalNames.isNotEmpty) {
  //     print(
  //       '🧹 Cleared localName for userIds (deleted from phone): $clearedLocalNames',
  //     );
  //   } else {
  //     print('✅ No contacts were removed from phone, nothing to clear.');
  //   }

  //   print('📥 Inserted/Updated ${insertedUsers.length} users: $insertedUsers');
  // }

  // Future<bool> updateUserOnlineStatus(
  //   int userId,
  //   int isOnline,
  //   String lastSeenTime,
  // ) async {
  //   final db = await DataBaseService().database;
  //   final rowsUpdated = await db.update(
  //     tableName,
  //     {'isOnline': isOnline, 'lastSeen': lastSeenTime},
  //     where: 'userId = ?',
  //     whereArgs: [userId],
  //   );
  //   return rowsUpdated > 0;
  // }
  Future<void> saveAllStatuses(List<Statusmodel> list) async {
    final db = await DataBaseService().database;

    print("💾 Saving ${list.length} statuses into SQLite...");

    // await db.delete(tableName);
    print("🧹 Old statuses cleared.");

    final batch = db.batch();

    for (var s in list) {
      print(" Inserting Status -> id=${s.id}, userId=${s.userId}, url=${s.assetUrl}");

      batch.insert(
        tableName,
        {
          "id": s.id,
          "userId": s.userId,
          "isAsset": s.isAsset,
          "statusText": s.statusText!.isEmpty ? null:s.statusText!,
          "assetUrl": s.assetUrl,
          "statusAssetType": s.statusAssetType,
          "createdAt": s.createdAt,
          "isDeleted": s.isDeleted ?? 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print("All statuses inserted successfully!");
  }
  Future<List<Statusmodel>> getAllStatuses() async {
    final db = await DataBaseService().database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableName, orderBy: "createdAt ASC");

    return List.generate(maps.length, (i) {
      return Statusmodel.fromJson(maps[i]);
    });
  }

}
