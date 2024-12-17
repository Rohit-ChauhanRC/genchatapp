import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/constants/message_enum.dart';
import 'package:genchatapp/app/data/models/message_model.dart';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class MessageTable {
  final tableName = messageTable;
  final deleteQueueTblName = deleteQueueTable;

  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER ,
        messageId TEXT NOT NULL UNIQUE,
        senderId TEXT NOT NULL,
        receiverId TEXT NOT NULL,
        text TEXT NOT NULL,
        type TEXT NOT NULL,
        timeSent INTEGER NOT NULL,
        status TEXT NOT NULL,
        repliedMessage TEXT NOT NULL,
        repliedTo TEXT NOT NULL,
        repliedMessageType TEXT NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'pending',
        PRIMARY KEY ("id" AUTOINCREMENT)
      )
    ''');
  }

  Future<void> createDeletionQueueTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $deleteQueueTblName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        messageId TEXT NOT NULL UNIQUE
      )
    ''');
  }

  Future<void> insertOrUpdateMessage(MessageModel message) async {
    final existingMessage = await getMessageById(message.messageId);
    if (existingMessage == null) {
      await insertMessage(message);
    } else {
      await updateMessage(message);
    }
  }

  Future<List<MessageModel>> fetchMessages({
    required String senderId,
    required String receiverId,
  }) async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      where:
      '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [senderId, receiverId, receiverId, senderId],
      orderBy: 'timeSent ASC',
    );

    return result.map((map) => MessageModel.fromMap(map)).toList();
  }

  Future<void> insertMessage(MessageModel message) async {
    final db = await DataBaseService().database;

    await db.insert(
      tableName,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateMessage(MessageModel message) async {
    final db = await DataBaseService().database;
    return await db.update(
      tableName,
      message.toMap(),
      where: 'messageId = ?',
      whereArgs: [message.messageId],
    );
  }

  /// Retrieve a message by its ID
  Future<MessageModel?> getMessageById(String messageId) async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      where: 'messageId = ?',
      whereArgs: [messageId],
    );

    if (result.isNotEmpty) {
      return MessageModel.fromMap(result.first);
    }
    return null;
  }



Future<List<MessageModel>> fetchUnsentMessages() async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      where: 'syncStatus = ?',
      whereArgs: ['pending'],
    );

    // Debugging: Log the result
    // print("Fetched unsent messages: $result");

    return result.map((map) {
      // Debugging: Log individual message maps
      // print("Mapping unsent message: $map");
      return MessageModel.fromMap(map);
    }).toList();
  }

  Future<void> updateSyncStatus(String messageId, String syncStatus, MessageStatus msgStatus) async {
    final db = await DataBaseService().database;
    await db.update(
      tableName,
      {'syncStatus': syncStatus,
        'status': msgStatus.type
      },
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
  }

  //For delete msg------------>

  Future<void> deleteMessage(String messageId) async {
    final db = await DataBaseService().database;
    await db.delete(tableName, where: 'messageId = ?', whereArgs: [messageId]);
  }

  Future<void> markForDeletion(String messageId) async {
    try {
      final db = await DataBaseService().database;
      await db.insert(deleteQueueTblName, {'messageId': messageId},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (e) {
      print("Error marking message for deletion: $e");
    }
  }

  Future<List<String>> getQueuedDeletions() async {
    final db = await DataBaseService().database;
    final result = await db.query(deleteQueueTblName);
    return result.map((row) => row['messageId'] as String).toList();
  }

  Future<void> removeQueuedDeletion(String messageId) async {
    final db = await DataBaseService().database;
    await db.delete(deleteQueueTblName, where: 'messageId = ?', whereArgs: [messageId]);
  }

  Future<void> updateMessageContent({
    required String messageId,
    required String newText,
  }) async {
    final db = await DataBaseService().database;
    await db.update(
      tableName,
      {'text': newText},
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
  }


  //
  // // Update message status
  // Future<void> updateMessageStatus(String messageId, String status) async {
  //   final db = await DataBaseService().database;
  //   await db.update(
  //     'messages',
  //     {'status': status},
  //     where: 'messageId = ?',
  //     whereArgs: [messageId],
  //   );
  // }
}
