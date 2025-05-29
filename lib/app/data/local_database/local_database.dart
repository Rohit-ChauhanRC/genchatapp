
import 'package:genchatapp/app/data/local_database/groups_table.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../config/services/folder_creation.dart';
import '../../services/shared_preference_service.dart';
import 'chatconnect_table.dart';
import 'contacts_table.dart';
import 'message_table.dart';

import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

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
      version: 3,
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
    await GroupsTable().createTable(database);
    // await ProfileDB().createTable(database);
  }

  void onUpgrade(Database database, int oldVersion, int newVersion) async {
    MessageTable().onUpgrade(database, oldVersion, newVersion);
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



extension BackupRestore on DataBaseService {

  /// Backup the database file to external storage
  Future<void> backupDatabase() async {
    if (_userId == null) throw Exception("User ID not set.");

    final permissionGranted = await Permission.manageExternalStorage.request();
    if (!permissionGranted.isGranted) {
      throw Exception("Storage permission not granted");
    }

    final sourcePath = await fullPath;
    final backupDir = Directory('/storage/emulated/0/GenChatBackup');
    if (!await backupDir.exists()) await backupDir.create(recursive: true);

    final backupPath = '${backupDir.path}/genchat_$_userId.db';
    final dbFile = File(sourcePath);

    if (await dbFile.exists()) {
      await dbFile.copy(backupPath);
    } else {
      throw Exception("Database file does not exist.");
    }
  }

  /// Restore the database file from backup
  Future<void> restoreDatabase() async {
    if (_userId == null) throw Exception("User ID not set.");

    final backupPath = '/storage/emulated/0/GenChatBackup/genchat_$_userId.db';
    final sourcePath = await fullPath;
    final backupFile = File(backupPath);

    if (!await backupFile.exists()) {
      throw Exception("No backup found for user $_userId.");
    }

    await closeDb(); // Important: close connection before overwriting
    await File(sourcePath).writeAsBytes(await backupFile.readAsBytes());
  }

  Future<bool> hasBackup() async {
    if (_userId == null) return false;
    final backupPath = '/storage/emulated/0/GenChatBackup/genchat_$_userId.db';
    return File(backupPath).exists();
  }

}
