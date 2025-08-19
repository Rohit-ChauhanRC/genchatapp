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
      version: 9,
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
  }

  void onUpgrade(Database database, int oldVersion, int newVersion) async {
    MessageTable().onUpgrade(database, oldVersion, newVersion);
    ContactsTable().onUpgrade(database, oldVersion, newVersion);
    ChatConectTable().onUpgrade(database, oldVersion, newVersion);
  }

  Future<void> closeDb() async {
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
    await GroupsTable().deleteGroupsTable();
  }
}

extension BackupRestore on DataBaseService {
  /// Backup the database file to external storage
  // Future<void> backupDatabase() async {
  //   if (_userId == null) throw Exception("User ID not set.");
  //
  //   final permissionGranted = await Permission.manageExternalStorage.request();
  //   if (!permissionGranted.isGranted) {
  //     throw Exception("Storage permission not granted");
  //   }
  //
  //   final sourcePath = await fullPath;
  //   final backupDir = Directory('/storage/emulated/0/GenChatBackup');
  //   if (!await backupDir.exists()) await backupDir.create(recursive: true);
  //
  //   final backupPath = '${backupDir.path}/genchat_$_userId.db';
  //   final dbFile = File(sourcePath);
  //
  //   if (await dbFile.exists()) {
  //     await dbFile.copy(backupPath);
  //   } else {
  //     throw Exception("Database file does not exist.");
  //   }
  // }

  Future<void> backupAllData({
    required void Function(
      int done,
      int total,
      int uploadedBytes,
      int totalBytes,
    )
    onProgress,
  }) async {
    if (_userId == null) throw Exception("User ID not set.");

    final root = await folderCreation.getRootFolderPath();
    final dbPath = await fullPath;
    final userBackupDir = Directory(
      '/storage/emulated/0/GenChatBackup/$_userId',
    );
    if (!userBackupDir.existsSync()) userBackupDir.createSync(recursive: true);

    final mediaTypes = [
      'Image',
      'Video',
      'Document',
      "Audio",
      "GIFs",
      "Backups",
      "Thumbnail",
    ];
    int totalFiles = 0;
    int copiedFiles = 0;
    int totalBytes = 0;
    int uploadedBytes = 0;

    // Calculate total size first
    final allFiles = <File>[];

    for (final type in mediaTypes) {
      final dir = Directory('$root$type');
      if (dir.existsSync()) {
        allFiles.addAll(dir.listSync().whereType<File>());
      }
    }

    // Add DB file to the list
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      allFiles.insert(0, dbFile); // Ensure DB is first
    }

    totalFiles = allFiles.length;
    for (final file in allFiles) {
      totalBytes += await file.length();
    }

    // Start copying files
    for (final file in allFiles) {
      final isDb = file.path == dbPath;
      String destPath;

      if (isDb) {
        destPath = '${userBackupDir.path}/genchat_$_userId.db';
      } else {
        final name = file.path.split('/').last;
        final type = file.parent.path.split('/').last;
        final toDir = Directory('${userBackupDir.path}/$type');
        if (!toDir.existsSync()) toDir.createSync(recursive: true);
        destPath = '${toDir.path}/$name';
      }

      final newFile = await file.copy(destPath);
      copiedFiles++;
      uploadedBytes += await newFile.length();

      onProgress(copiedFiles, totalFiles, uploadedBytes, totalBytes);
    }
  }

  /// Restore the database file from backup
  // Future<void> restoreDatabase() async {
  //   if (_userId == null) throw Exception("User ID not set.");
  //
  //   final backupPath = '/storage/emulated/0/GenChatBackup/genchat_$_userId.db';
  //   final sourcePath = await fullPath;
  //   final backupFile = File(backupPath);
  //
  //   if (!await backupFile.exists()) {
  //     throw Exception("No backup found for user $_userId.");
  //   }
  //
  //   await closeDb(); // Important: close connection before overwriting
  //   await File(sourcePath).writeAsBytes(await backupFile.readAsBytes());
  // }

  Future<void> restoreAllData({
    required void Function(int done, int total, int copiedBytes, int totalBytes)
    onProgress,
  }) async {
    if (_userId == null) throw Exception("User ID not set.");

    final backupDir = Directory('/storage/emulated/0/GenChatBackup/$_userId');
    final dbFile = File('${backupDir.path}/genchat_$_userId.db');
    final destDbPath = await fullPath;

    if (!await dbFile.exists())
      throw Exception("No backup found for user $_userId.");

    final mediaFolders = ['Image', 'Video', 'Document'];
    int totalFiles = 1;
    int copied = 0;
    int totalBytes = 0;
    int copiedBytes = 0;

    // Get total size of all files
    if (await backupDir.exists()) {
      await for (final entity in backupDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }
    }

    // 1. Copy DB file
    final dbData = await dbFile.readAsBytes();
    await closeDb();
    await File(destDbPath).writeAsBytes(dbData);
    copied++;
    copiedBytes += dbData.length;
    onProgress(copied, totalFiles, copiedBytes, totalBytes);

    // 2. Copy media files
    final rootFolder = await folderCreation.getRootFolderPath();
    for (final folder in mediaFolders) {
      final fromDir = Directory('${backupDir.path}/$folder');
      final toDir = Directory('$rootFolder$folder');

      if (!await toDir.exists()) await toDir.create(recursive: true);

      if (await fromDir.exists()) {
        final files = fromDir.listSync().whereType<File>();
        totalFiles += files.length;

        for (final file in files) {
          final name = file.path.split('/').last;
          final newFile = File('${toDir.path}/$name');
          final bytes = await file.readAsBytes();
          await newFile.writeAsBytes(bytes);

          copied++;
          copiedBytes += bytes.length;
          onProgress(copied, totalFiles, copiedBytes, totalBytes);
        }
      }
    }
  }

  Future<bool> hasBackup() async {
    if (_userId == null) return false;
    // final backupPath = '/storage/emulated/0/GenChatBackup/genchat_$_userId.db';
    // return File(backupPath).exists();
    final basePath = '/storage/emulated/0/GenChatBackup/$_userId';
    return File('$basePath/genchat_$_userId.db').exists();
  }
}
