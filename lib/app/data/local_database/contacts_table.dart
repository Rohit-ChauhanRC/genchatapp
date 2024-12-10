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

  Future<void> deleteTable() async {
    final db = await DataBaseService().database;

    // database.delete(tableName);
    // final db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
    await createTable(db);
    print('Table "$tableName" deleted successfully.');
  }
}
