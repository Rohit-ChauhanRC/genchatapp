import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'; // To get storage paths

import 'chatconnect_table.dart';
import 'contacts_table.dart';
import 'message_table.dart';

class DataBaseService {
  Database? _database;

  Future<Database> get database async {
    //
    if (_database != null) {
      return _database!;
    }

    _database = await _initialize();
    return _database!;
  }

  Future<String> get fullPath async {
    Directory baseDir;

    // Application documents directory (iOS and others)
    baseDir = await getApplicationDocumentsDirectory();
    const name = 'genmakgenchat.db';
    // final path = await getDatabasesPath();
    return join(baseDir.path, 'GenChatApp/Database', name);
    // return join(path, name);
  }

  Future<Database> _initialize() async {
    // print(await fullPath);
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 2,
      onCreate: create,
      singleInstance: true,
      onUpgrade: onUpgrade,
    );
    return database;
  }

  Future<void> create(Database database, int verion) async {
    await MessageTable().createTable(database);
    await ContactsTable().createTable(database);
    await ChatConectTable().createTable(database);
    await MessageTable().createDeletionQueueTable(database);
    // await ProfileDB().createTable(database);
  }

  void onUpgrade(Database database, int oldVersion, int newVersion) async {
    // MilkCollectionDB().onUpgrade(database, oldVersion, newVersion);
    // VendorDB().onUpgrade(database, oldVersion, newVersion);
    // ReceivingDB().onUpgrade(database, oldVersion, newVersion);
    // SellDB().onUpgrade(database, oldVersion, newVersion);
    // ProfileDB().onUpgrade(database, oldVersion, newVersion);
  }

  void closeDb() {
    _database?.close();
  }
}
