import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class ChatConectTable {
  final tableName = chatConnectTable;

  Future<void> createTable(Database database) async {
    await database.execute("""
  CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" TEXT,
    "profilePic" TEXT,
    "contactId" TEXT,
    "timeSent" TEXT,
    "lastMessage" TEXT,
    "lastMessageId" INTEGER,
    "uid" TEXT,
    "unreadCount" INTEGER,
    "isGroup" INTEGER,
    UNIQUE(uid, isGroup)
  );
""");
  }

  Future<int> insert({required ChatConntactModel contact}) async {
    final database = await DataBaseService().database;

    return await database.insert(
      tableName,
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatConntactModel>> fetchAll() async {
    final database = await DataBaseService().database;
    final e = await database.rawQuery('''
        SELECT * from $tableName
      ''');

    return e.map((el) => ChatConntactModel.fromMap((el))).toList();
  }

  Future<List<ChatConntactModel>> fetchAllWithoutGroup() async {
    final database = await DataBaseService().database;
    final e = await database.query(tableName, where: 'isGroup = 0');

    return e.map((el) => ChatConntactModel.fromMap((el))).toList();
  }

  Future<ChatConntactModel?> fetchById({
    required String uid,
    required bool isGroup,
  }) async {
    final database = await DataBaseService().database;

    // Query the database with the UID condition
    final result = await database.query(
      tableName,
      where: 'uid = ? AND isGroup = ?', // Add WHERE clause
      whereArgs: [uid, isGroup ? 1 : 0], // Provide arguments for WHERE
      limit: 1, // Limit to 1 result for efficiency
    );

    // If a result is found, return the ContactModel, otherwise return null
    if (result.isNotEmpty) {
      return ChatConntactModel.fromMap(result.first);
    }

    return null;
  }

  Future<ChatConntactModel?> fetchUserById({required String uid}) async {
    final database = await DataBaseService().database;

    // Query the database with the UID condition
    final result = await database.query(
      tableName,
      where: 'uid = ?', // Add WHERE clause
      whereArgs: [uid], // Provide arguments for WHERE
      limit: 1, // Limit to 1 result for efficiency
    );

    // If a result is found, return the ContactModel, otherwise return null
    if (result.isNotEmpty) {
      return ChatConntactModel.fromMap(result.first);
    }

    return null;
  }

  Future<void> updateContact({
    required String uid,
    required int isGroup,
    int? lastMessageId,
    String? profilePic,
    String? lastMessage,
    String? timeSent,
    String? name,
    int? unreadCount,
  }) async {
    final db = await DataBaseService().database;

    final updatedValues = <String, dynamic>{};
    if (profilePic != null) updatedValues['profilePic'] = profilePic;
    if (lastMessage != null) updatedValues['lastMessage'] = lastMessage;
    if (lastMessageId != null) updatedValues['lastMessageId'] = lastMessageId;
    if (timeSent != null) updatedValues['timeSent'] = timeSent;
    if (name != null) updatedValues['name'] = name;
    if (unreadCount != 0) updatedValues["unreadCount"] = unreadCount;
    if (isGroup != null) updatedValues["isGroup"] = isGroup;

    print(
      '📥 [updateContact] Updating contact (uid=$uid) with values: $updatedValues',
    );

    if (updatedValues.isNotEmpty) {
      await db.update(
        tableName,
        updatedValues,
        where: 'uid = ? AND isGroup = ?',
        whereArgs: [uid, isGroup],
      );
    } else {
      print('⚠️ [updateContact] No values to update for uid=$uid');
    }
  }

  Future<bool> isGroupContact(String uid) async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );
    if (result.isNotEmpty) {
      final row = result.first;
      return row['isGroup'] == 1;
    }
    return false;
  }

  Future<void> insertOrUpdateGroupChat(ChatConntactModel contact) async {
    final db = await DataBaseService().database;

    // Check if record already exists
    final existing = await db.query(
      tableName,
      where: 'uid = ? AND isGroup = ?',
      whereArgs: [contact.uid, 1],
    );

    if (existing.isEmpty) {
      // Insert if doesn't exist
      await db.insert(
        tableName,
        contact.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      // Exists – only update selective fields (not lastMessage, lastMessageId, or timeSent)
      final updatedValues = {
        "name": contact.name,
        "profilePic": contact.profilePic,
        "isGroup": 1,
      };

      await db.update(
        tableName,
        updatedValues,
        where: 'uid = ? AND isGroup = ?',
        whereArgs: [contact.uid, 1],
      );
    }
  }

  Future<void> deleteChatUser(String uid) async {
    final db = await DataBaseService().database;
    await db.delete(tableName, where: 'uid = ?', whereArgs: [uid]);
  }

  Future<void> deleteTable() async {
    final db = await DataBaseService().database;

    // database.delete(tableName);
    // final db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
    await createTable(db);
    // print('Table "$tableName" deleted successfully.');
  }

  void onUpgrade(Database db, int oldVersion, int newVersion) {
    // if (oldVersion < newVersion) {
    //   db.execute("ALTER TABLE $tableName ADD COLUMN newCol TEXT;");
    // }
  }
}
