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
    "contactNumber" TEXT,
    "image" TEXT,
    "uid" TEXT,
    PRIMARY KEY("id" AUTOINCREMENT)
  );
""");
  }

  Future<int> create({
    required String fullName,
    required String contactNumber,
    String? image,
    required String uid,
  }) async {
    final database = await DataBaseService().database;
    return await database.rawInsert(
      '''
        INSERT INTO $tableName (fullName,
       contactNumber,
       image,
       uid) VALUES (?,?,?,?)
      ''',
      [
        fullName,
        contactNumber,
        image,
        uid,
      ],
    );
  }

  //   Future<List<ContactModel>> fetchAll() async {
  //   final database = await DataBaseService().database;
  //   final farmers = await database.rawQuery('''
  //       SELECT * from $tableName
  //     ''');

  //   return farmers.map((e) => ContactModel.(e)).toList();
  // }
}
