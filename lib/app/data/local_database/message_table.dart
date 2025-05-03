import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/new_message_model.dart';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class MessageTable {
  final tableName = messageTable;
  final deleteQueueTblName = deleteQueueTable;

  // Create message table
  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        messageId INTEGER,
        clientSystemMessageId TEXT UNIQUE,
        senderId INTEGER,
        recipientId INTEGER,
        message TEXT,
        state INTEGER,
        messageSentFromDeviceTime TEXT,
        createdAt TEXT,
        syncStatus TEXT,
        senderPhoneNumber TEXT,
        messageType TEXT,
        isForwarded INTEGER,
        isRepliedMessage INTEGER,
        messageRepliedOnId INTEGER,
        messageRepliedOn TEXT,
        messageRepliedOnType TEXT,
        isAsset INTEGER,
        assetOriginalName TEXT,
        assetServerName TEXT,
        assetUrl TEXT
      )
    ''');
  }

  // Create deletion queue table
  Future<void> createDeletionQueueTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $deleteQueueTblName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        messageId INTEGER NOT NULL UNIQUE,
        deleteState INTEGER NOT NULL
      )
    ''');
  }

  // Insert or update a message based on messageId
  Future<void> insertOrUpdateMessage(NewMessageModel message) async {
    final existingMessage = await getMessageById(message.messageId!);
    if (existingMessage == null) {
      await insertMessage(message);
    } else {
      await updateMessage(message);
    }
  }

  // Fetch messages between sender & receiver
  Future<List<NewMessageModel>> fetchMessages({
    required int receiverId,
    required int senderId,
  }) async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      where:
          '(senderId = ? AND recipientId = ?) OR (senderId = ? AND recipientId = ?)',
      whereArgs: [senderId, receiverId, receiverId, senderId],
      // orderBy: 'messageSentFromDeviceTime ASC',
    );

    return result.map((map) => NewMessageModel.fromMap(map)).toList();
  }

  // Insert a new message
  Future<void> insertMessage(NewMessageModel message) async {
    final db = await DataBaseService().database;

    // debugPrint("meesageSent: ${message.message}");

    await db.insert(
      tableName,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update message by messageId
  Future<int> updateMessage(NewMessageModel message) async {
    final db = await DataBaseService().database;
    return await db.update(
      tableName,
      message.toMap(),
      where: 'messageId = ?',
      whereArgs: [message.messageId],
    );
  }

//     final database = await DataBaseService().database;
//     return await database.update(
//       tableName,
//       {
//         if (name != null) 'name': name,
//         if (profilePic != null) 'profilePic': profilePic,
//         if (isOnline != null) 'isOnline': isOnline,
//         if (phoneNumber != null) 'phoneNumber': phoneNumber,
//         if (groupId != null) 'groupId': groupId,
//         if (email != null) 'email': email,
//         if (fcmToken != null) 'fcmToken': fcmToken,
//         if (lastSeen != null) 'lastSeen': lastSeen,
//       },
//       where: 'uid = ?',
//       conflictAlgorithm: ConflictAlgorithm.rollback,
//       whereArgs: [uid],
//     );

  Future<int> updateAckMessage(
      {required String clientSystemMessageId,
      required int state,
      required int messageId,
      required SyncStatus syncStatus}) async {
    final db = await DataBaseService().database;
    return await db.update(
      tableName,
      {"state": state, "messageId": messageId, "syncStatus": syncStatus.value},
      where: 'clientSystemMessageId = ?',
      whereArgs: [clientSystemMessageId],
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  Future<int> updateAckStateMessage(
      {required String messageId, required int state}) async {
    final db = await DataBaseService().database;
    return await db.update(
      tableName,
      {
        "state": state,
      },
      where: 'messageId = ?',
      whereArgs: [messageId],
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  // Get message by messageId
  Future<NewMessageModel?> getMessageById(int messageId) async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      where: 'messageId = ?',
      whereArgs: [messageId],
    );

    if (result.isNotEmpty) {
      return NewMessageModel.fromMap(result.first);
    }
    return null;
  }

  Future<bool> isLastMessage(int messageId) async {
    final db = await DataBaseService().database;

    final result = await db.rawQuery('''
    SELECT messageId FROM $tableName
    ORDER BY messageSentFromDeviceTime DESC
    LIMIT 1
  ''');

    if (result.isNotEmpty) {
      return result.first['messageId'] == messageId;
    }

    return false;
  }

  Future<NewMessageModel?> getLatestMessageForUser(int uid) async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      where: 'recipientId = ?',
      whereArgs: [uid],
      orderBy: 'messageSentFromDeviceTime DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return NewMessageModel.fromMap(result.first);
    }

    return null;
  }



  Future<NewMessageModel?> getMessageByClientID(
      String clientSystemMessageId) async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      where: 'clientSystemMessageId = ?',
      whereArgs: [clientSystemMessageId],
    );

    if (result.isNotEmpty) {
      return NewMessageModel.fromMap(result.first);
    }
    return null;
  }

  // Fetch messages not yet synced
  Future<List<NewMessageModel>> fetchUnsentMessages() async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      where: 'syncStatus = ?',
      whereArgs: ['pending'],
    );

    return result.map((map) => NewMessageModel.fromMap(map)).toList();
  }

  // Update syncStatus and state by messageId
  Future<void> updateSyncStatus(
      String messageId, SyncStatus syncStatus, MessageState state) async {
    final db = await DataBaseService().database;
    await db.update(
      tableName,
      {
        'syncStatus': syncStatus.value,
        'state': state.value,
      },
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
  }

  // Delete a message
  Future<void> deleteMessage(int messageId) async {
    final db = await DataBaseService().database;
    await db.delete(tableName, where: 'messageId = ?', whereArgs: [messageId]);
  }

  // Delete a message By ClientSystemMessageId
  Future<void> deleteMessageByClientSystemMessageId(String clientSystemMessageId) async {
    final db = await DataBaseService().database;
    await db.delete(tableName, where: 'clientSystemMessageId = ?', whereArgs: [clientSystemMessageId]);
  }


  // Add to deletion queue
  Future<void> markForDeletion({
    required int messageId,
    required bool isDeleteFromEveryone,
  }) async {
    try {
      final db = await DataBaseService().database;
      await db.insert(
          deleteQueueTblName,
          {
            'messageId': messageId,
            'deleteState': isDeleteFromEveryone ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore
      );
    } catch (e) {
      print("Error marking message for deletion: $e");
    }
  }

  // Get all queued deletions
  Future<List<Map<String, dynamic>>> getQueuedDeletions() async {
    final db = await DataBaseService().database;
    final result = await db.query(deleteQueueTblName);
    return result.map((row) => {
      'messageId': row['messageId'],
      'deleteState': row['deleteState'] == 1, // true or false
    }).toList();
  }

  // Remove from deletion queue
  Future<void> removeQueuedDeletion(int messageId) async {
    final db = await DataBaseService().database;
    await db.delete(deleteQueueTblName,
        where: 'messageId = ?', whereArgs: [messageId]);
  }

  Future<void> updateMessageContent({
    required int messageId,
    required String newText,
    required MessageType newType,
  }) async {
    final db = await DataBaseService().database;
    await db.update(
      tableName,
      {'message': newText, 'messageType': newType.value,},
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> deleteMessagesForUser(int userId) async {
    final db = await DataBaseService().database;

    await db.delete(
      tableName,
      where: '(senderId = ? OR recipientId = ?)',
      whereArgs: [userId, userId],
    );
  }


  Future<List<NewMessageModel>> getAllMessages() async {
    final db = await DataBaseService().database;
    final result = await db.query(tableName);

    return result.map((map) => NewMessageModel.fromMap(map)).toList();
  }

  Future<bool> messageExists(int messageId) async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      where: 'messageId = ?',
      whereArgs: [messageId],
      limit: 1,
    );
    return result.isNotEmpty;
  }


  Future<void> deleteMessageTable() async {
    final db = await DataBaseService().database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
    await createTable(db);
  }

  Future<void> deleteQueueMessageTable() async {
    final db = await DataBaseService().database;
    await db.execute('DROP TABLE IF EXISTS $deleteQueueTblName');
    await createDeletionQueueTable(db);
  }
}
