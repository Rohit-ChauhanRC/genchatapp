import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/data/models/message_model.dart';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class MessageTable {
  final tableName = messageTable;

  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER ,
        messageId TEXT NOT NULL UNIQUE,
        senderId TEXT NOT NULL,
        receiverId TEXT NOT NULL,
        text TEXT NOT NULL,
        type TEXT NOT NULL,
        timeSent TEXT NOT NULL,
        status TEXT NOT NULL,
        repliedMessage TEXT NOT NULL,
        repliedTo TEXT NOT NULL,
        repliedMessageType TEXT NOT NULL,
        PRIMARY KEY ("id" AUTOINCREMENT)
      )
    ''');
  }

  Future<void> insertMessage(MessageModel message) async {
    final db = await DataBaseService().database;

    await db.insert(
      tableName,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MessageModel>> fetchMessages(
      String senderId, String receiverId) async {
    final db = await DataBaseService().database;
    final result = await db.query(
      tableName,
      where:
          '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [senderId, receiverId, receiverId, senderId],
      orderBy: 'timestamp ASC',
    );

    return result.map((map) => MessageModel.fromMap(map)).toList();
  }

  // Update message status
  Future<void> updateMessageStatus(String messageId, String status) async {
    final db = await DataBaseService().database;
    await db.update(
      'messages',
      {'status': status},
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
  }
}
