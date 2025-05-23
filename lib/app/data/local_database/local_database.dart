
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../config/services/folder_creation.dart';
import '../../services/shared_preference_service.dart';
import 'chatconnect_table.dart';
import 'contacts_table.dart';
import 'message_table.dart';

class DataBaseService {
  Database? _database;
  final FolderCreation folderCreation = Get.find<FolderCreation>();

  String? _userId; // Unique identifier for the user

  void setUserId(String userId) {
    _userId = userId;
  }

  Future<Database> get database async {
    //
    if (_userId == null) {
      final sharedPrefs = Get.find<SharedPreferenceService>();
      final userId = sharedPrefs.getUserData()?.userId.toString();

      if (userId == null) {
        throw Exception("User ID not available in SharedPreferences.");
      }
      _userId = userId;
    }

    if (_database != null) {
      return _database!;
    }

    _database = await _initialize();
    return _database!;
  }

  Future<String> get fullPath async {
    String baseDir;

    // Application documents directory (iOS and others)
    // baseDir = await getApplicationDocumentsDirectory();
    baseDir = await folderCreation.getRootFolderPath();
    final dbName = 'genchat_$_userId.db';
    // final path = await getDatabasesPath();
    return join(baseDir, 'Database', dbName);
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

  Future<void> closeDb() async{
    // Optional: clear current in-memory references only
    _database?.close();
    _database = null;
  }

  Future<void> clearUserData() async {
    // Optional: clear tables if needed
    await MessageTable().deleteMessageTable();
    await ContactsTable().deleteTable();
    await ChatConectTable().deleteTable();
    await MessageTable().deleteQueueMessageTable();
  }
}
