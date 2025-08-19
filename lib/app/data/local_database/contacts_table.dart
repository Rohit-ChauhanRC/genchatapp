import 'package:genchatapp/app/constants/constants.dart';
import 'package:sqflite/sqflite.dart';
import '../models/new_models/response_model/contact_response_model.dart';
import 'local_database.dart';

class ContactsTable {
  final tableName = contactsDb;

  Future<void> createTable(Database database) async {
    await database.execute("""
      CREATE TABLE IF NOT EXISTS $tableName (
        userId INTEGER PRIMARY KEY,
        countryCode INTEGER,
        phoneNumber TEXT UNIQUE,
        name TEXT,
        localName TEXT,
        email TEXT,
        userDescription TEXT,
        isOnline INTEGER,
        displayPicture TEXT,
        displayPictureUrl TEXT,
        lastSeen TEXT,
        isBlocked INTEGER,
        blockedByMe INTEGER
      );
    """);
  }

  Future<int> create(UserList user) async {
    final db = await DataBaseService().database;
    return await db.insert(
      tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> createBulk(List<UserList> users) async {
    final db = await DataBaseService().database;

    // 1. Fetch all existing contacts with userId and localName
    final existing = await db.query(
      tableName,
      columns: ['userId', 'localName'],
    );
    final existingMap = {
      for (var row in existing)
        row['userId'].toString(): (row['localName'] ?? '') as String,
    };

    // 2. Get new userIds from the incoming contacts list
    final newUserIds = users.map((u) => u.userId.toString()).toSet();

    final batch = db.batch();

    // List to keep track of changes for logging
    final clearedLocalNames = <String>[];
    final insertedUsers = <String>[];

    // 3. Identify userIds that were in DB earlier but not in new list → deleted from phone
    for (final oldUserId in existingMap.keys) {
      if (!newUserIds.contains(oldUserId)) {
        // This contact was removed from phone — clear only localName
        batch.update(
          tableName,
          {'localName': ''},
          where: 'userId = ?',
          whereArgs: [int.parse(oldUserId)],
        );
        clearedLocalNames.add(oldUserId);
      }
    }

    // 4. Insert/update the current contacts from API+phone sync
    for (final user in users) {
      batch.insert(
        tableName,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      insertedUsers.add(user.userId.toString());
    }

    await batch.commit(noResult: true);

    // 5. Logging
    if (clearedLocalNames.isNotEmpty) {
      print(
        '🧹 Cleared localName for userIds (deleted from phone): $clearedLocalNames',
      );
    } else {
      print('✅ No contacts were removed from phone, nothing to clear.');
    }

    print('📥 Inserted/Updated ${insertedUsers.length} users: $insertedUsers');
  }

  Future<List<UserList>> fetchAll() async {
    final db = await DataBaseService().database;
    final result = await db.query(tableName);
    return result.map((e) => UserList.fromMap(e)).toList();
  }

  Future<bool> updateUserOnlineStatus(
    int userId,
    int isOnline,
    String lastSeenTime,
  ) async {
    final db = await DataBaseService().database;
    final rowsUpdated = await db.update(
      tableName,
      {'isOnline': isOnline, 'lastSeen': lastSeenTime},
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return rowsUpdated > 0;
  }

  Future<UserList?> getUserById(int userId) async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return UserList.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<void> insertPlaceholderUser({
    required int userId,
    required int countryCode,
    required int isOnline,
    required String phoneNumber,
    required String name,
    required String localName,
    required String email,
    required String userDescription,
    required String displayPicture,
    required String displayPictureUrl,
    required String lastSeen,
    required int isBlocked,
    required int? blockedByMe,
  }) async {
    final db = await DataBaseService().database;

    final placeholderUser = {
      'userId': userId,
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'name': name,
      'localName': localName,
      'email': email,
      'userDescription': userDescription,
      'isOnline': isOnline,
      'displayPicture': displayPicture,
      'displayPictureUrl': displayPictureUrl,
      'lastSeen': lastSeen,
      'isBlocked': isBlocked,
      'blockedByMe': blockedByMe,
    };

    await db.insert(
      tableName,
      placeholderUser,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> updateUserFields({
    required int userId,
    String? name,
    String? localName,
    String? phoneNumber,
    String? email,
    String? userDescription,
    String? displayPicture,
    String? displayPictureUrl,
    int? blockedByMe,
    int? isBlocked,
  }) async {
    final db = await DataBaseService().database;

    // Build only non-null values to update
    final Map<String, dynamic> updateFields = {};
    if (name != null) updateFields['name'] = name;
    if (localName != null) updateFields['localName'] = localName;
    if (phoneNumber != null) updateFields['phoneNumber'] = phoneNumber;
    if (email != null) updateFields['email'] = email;
    if (blockedByMe != null) updateFields['blockedByMe'] = blockedByMe;
    if (isBlocked != null) updateFields['isBlocked'] = isBlocked;
    if (userDescription != null) {
      updateFields['userDescription'] = userDescription;
    }
    if (displayPicture != null) updateFields['displayPicture'] = displayPicture;
    if (displayPictureUrl != null) {
      updateFields['displayPictureUrl'] = displayPictureUrl;
    }

    print(
      '📥 [UpdateContactsTable] Updating contacts (userId=$userId) with values: $updateFields',
    );

    if (updateFields.isEmpty) {
      print('⚠️ No fields to update for userId=$userId');
      return;
    }

    // Try update — will update only if userId exists
    if (updateFields.isNotEmpty) {
      await db.update(
        tableName,
        updateFields,
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } else {
      print('⚠️ [updateContact] No values to update for uid=$userId');
    }
    // if (rowsAffected == 0) {
    //   print('ℹ️ No user found with userId=$userId. Skipping update.');
    // } else {
    //   print('✅ Updated $rowsAffected row(s) for userId=$userId');
    // }
  }

  void onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      db.execute("ALTER TABLE $tableName ADD COLUMN blockedByMe INTEGER;");
    }
  }

  Future<void> deleteTable() async {
    final db = await DataBaseService().database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
    await createTable(db);
  }

  Future<(bool?, int?)> isUserBlocked(int userId) async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      columns: ['isBlocked', 'blockedByMe'],
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final value = result.first['isBlocked'] as int?;
      final blockedByMe = result.first['blockedByMe'] as int?;

      if (value == null) {
        return (null, 0); // Means no data
      }
      return (value == 1, blockedByMe ?? 0); // 1 = blocked, 0 = not blocked
    }

    return (false, null); // User not found
  }

  Future<bool> updateUserBlockUnblock(
    int userId,
    int isBlocked,
    int? blockedByMe,
  ) async {
    final db = await DataBaseService().database;
    final rowsUpdated = await db.update(
      tableName,
      {'isBlocked': isBlocked, 'blockedByMe': blockedByMe},
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return rowsUpdated > 0;
  }
}
