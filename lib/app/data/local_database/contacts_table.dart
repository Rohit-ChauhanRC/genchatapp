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
        lastSeenTime TEXT,
        isBlocked INTEGER
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
    final batch = db.batch();

    for (final user in users) {
      batch.insert(
        tableName,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<UserList>> fetchAll() async {
    final db = await DataBaseService().database;
    final result = await db.query(tableName);
    return result.map((e) => UserList.fromMap(e)).toList();
  }

  Future<bool> updateUserOnlineStatus(int userId, int isOnline, String lastSeenTime) async {
    final db = await DataBaseService().database;
    final rowsUpdated = await db.update(
      tableName,
      {'isOnline': isOnline,
      'lastSeenTime': lastSeenTime},
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
    required int isOnline,
    required phoneNumber,
    required localName
  }) async {
    final db = await DataBaseService().database;

    final placeholderUser = {
      'userId': userId,
      'countryCode': 0,
      'phoneNumber': phoneNumber,
      'name': '',
      'localName': localName,
      'email': '',
      'userDescription': '',
      'isOnline': isOnline,
      'displayPicture': '',
      'displayPictureUrl': '',
      'lastSeenTime': '',
      'isBlocked': 0,
    };

    await db.insert(
      tableName,
      placeholderUser,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }


  Future<void> deleteTable() async {
    final db = await DataBaseService().database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
    await createTable(db);
  }
}



