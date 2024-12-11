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
    "timeSent" INTEGER,
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

  Future<void> updateContact({
    required int uid,
    String? profilePic,
    String? lastMessage,
    int? timeSent,
  }) async {
    final db = await DataBaseService().database;

    // Map with new values
    final updatedValues = {
      'profilePic': profilePic,
      'lastMessage': lastMessage,
      'timeSent': timeSent,
    };

    // Perform the update
    await db.update(
      tableName,
      updatedValues,
      where: 'uid = ?',
      whereArgs: [uid],
    );
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
