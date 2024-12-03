import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

import 'local_database.dart';

class GenchatUserDB {
  //
  final tableName = usersDb;

  Future<void> createTable(Database database) async {
    await database.execute("""
  CREATE TABLE IF NOT EXISTS $tableName (
    "name" TEXT,
    "uid" INTEGER ,
    "profilePic" TEXT,
    "isOnline" BOOL,
    "phoneNumber" TEXT,
    "groupId" TEXT,
    "email" TEXT,
    "fcmToken" TEXT,
    "lastSeen" TEXT,
    "id:"INTEGER,
    PRIMARY KEY("id" AUTOINCREMENT)
  );
""");
  }
  // PRIMARY KEY("id" AUTOINCREMENT)
  //

  Future<int> create({
    required String name,
    required String uid,
    String? profilePic,
    required bool isOnline,
    required String phoneNumber,
    String? groupId,
    String? email,
    String? fcmToken,
    String? lastSeen,
  }) async {
    final database = await DataBaseService().database;
    return await database.rawInsert(
      '''
        INSERT INTO $tableName (name,uid,profilePic,isOnline,phoneNumber,) VALUES (?,?,?,?,?,?,?,?,?)
      ''',
      [
        name,
        uid,
        profilePic,
        isOnline,
        phoneNumber,
        groupId,
        email,
        fcmToken,
        lastSeen,
      ],
    );
  }

  Future<List<UserModel>> fetchAll() async {
    final database = await DataBaseService().database;
    final farmers = await database.rawQuery('''
        SELECT * from $tableName 
      ''');

    return farmers.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<List<UserModel>> fetchByName(String name) async {
    final database = await DataBaseService().database;
    final farmers = await database.rawQuery('''
        SELECT * from $tableName WHERE name = ?
      ''', [name]);

    return farmers.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<UserModel> fetchById(String id) async {
    final database = await DataBaseService().database;
    final name = await database.rawQuery('''
        SELECT * from $tableName WHERE uid = ? 
      
      ''', [id]);
    return UserModel.fromMap(
        name.isNotEmpty ? name.first : <String, dynamic>{});
  }

  Future<int> update({
    String? name,
    required String uid,
    String? profilePic,
    bool? isOnline,
    String? phoneNumber,
    String? groupId,
    String? email,
    String? fcmToken,
    String? lastSeen,
  }) async {
    final database = await DataBaseService().database;
    return await database.update(
      tableName,
      {
        if (name != null) 'name': name,
        if (profilePic != null) 'profilePic': profilePic,
        if (isOnline != null) 'isOnline': isOnline,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (groupId != null) 'groupId': groupId,
        if (email != null) 'email': email,
        if (fcmToken != null) 'fcmToken': fcmToken,
        if (lastSeen != null) 'lastSeen': lastSeen,
      },
      where: 'uid = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [uid],
    );
  }

  Future<void> delete({required int id}) async {
    final database = await DataBaseService().database;

    await database.rawDelete('''
  DELETE FROM $tableName WHERE uid = ?
''', [id]);
  }

  Future<void> deleteTable() async {
    final database = await DataBaseService().database;

    await database.delete(tableName);
  }

  void onUpgrade(Database db, int oldVersion, int newVersion) {
    // if (oldVersion < newVersion) {
    //   db.execute("ALTER TABLE $tableName ADD COLUMN newCol TEXT;");
    // }
  }
}
