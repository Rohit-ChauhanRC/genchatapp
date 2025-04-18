import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/data/models/chat_conntact_model.dart';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class ChatConectTable {
  final tableName = chatConnectTable;

  Future<void> createTable(Database database) async {
    await database.execute("""
  CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER ,
    "name" TEXT,
    "profilePic" TEXT,
    "contactId" TEXT UNIQUE,
    "timeSent" TEXT,
    "lastMessage" TEXT,
    "uid" TEXT UNIQUE,
    PRIMARY KEY("id" AUTOINCREMENT)
  );
""");
  }

  Future<int> insert({
    required ChatConntactModel contact,
  }) async {
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
    for (var element in e) {
      print(element.values);
    }
    // print(e);
    return e.map((el) => ChatConntactModel.fromMap((el))).toList();
  }

  Future<ChatConntactModel?> fetchById({required String uid}) async {
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
    String? profilePic,
    String? lastMessage,
    String? timeSent,
    String? name,
  }) async {
    final db = await DataBaseService().database;

    final updatedValues = <String, dynamic>{};
    if (profilePic != null) updatedValues['profilePic'] = profilePic;
    if (lastMessage != null) updatedValues['lastMessage'] = lastMessage;
    if (timeSent != null) updatedValues['timeSent'] = timeSent;
    if (name != null) updatedValues['name'] = name;

    print('📥 [updateContact] Updating contact (uid=$uid) with values: $updatedValues');

    if (updatedValues.isNotEmpty) {
      await db.update(
        tableName,
        updatedValues,
        where: 'uid = ?',
        whereArgs: [uid],
      );
    } else {
      print('⚠️ [updateContact] No values to update for uid=$uid');
    }
  }


  Future<void> deleteTable() async {
    final db = await DataBaseService().database;

    // database.delete(tableName);
    // final db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
    await createTable(db);
    print('Table "$tableName" deleted successfully.');
  }

  void onUpgrade(Database db, int oldVersion, int newVersion) {
    // if (oldVersion < newVersion) {
    //   db.execute("ALTER TABLE $tableName ADD COLUMN newCol TEXT;");
    // }
  }
}
