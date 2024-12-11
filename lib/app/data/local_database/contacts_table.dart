import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/data/models/contact_model.dart';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class ContactsTable {
  final tableName = contactsDb;

  Future<void> createTable(Database database) async {
    await database.execute("""
  CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER ,
    "fullName" TEXT,
    "contactNumber" TEXT UNIQUE,
    "image" TEXT,
    "uid" TEXT UNIQUE,
    PRIMARY KEY("id" AUTOINCREMENT)
  );
""");
  }

  Future<int> create({
    required String fullName,
    required String contactNumber,
    String? imagePath,
    required String uid,
  }) async {
    final database = await DataBaseService().database;

    return await database.insert(
      tableName,
      {
        "fullName": fullName,
        "contactNumber": contactNumber,
        "image": imagePath,
        "uid": uid
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ContactModel>> fetchAll() async {
    final database = await DataBaseService().database;
    final e = await database.rawQuery('''
        SELECT * from $tableName
      ''');
    for (var element in e) {
      print(element.values);
    }
    // print(e);
    return e.map((el) => ContactModel.fromMap((el))).toList();
  }
  Future<ContactModel?> fetchByUid(String uid) async {
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
      return ContactModel.fromMap(result.first);
    }

    return null; // Return null if no contact is found
  }

  Future<void> updateContact({
    required int uid,
    String? imagePath,
  }) async {
    final db = await DataBaseService().database;

    // Map with new values
    final updatedValues = {
      'image': imagePath,
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
