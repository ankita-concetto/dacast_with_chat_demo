import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:webrtccommunication/utils/signaling_constants.dart';
import 'package:webrtccommunication_example/models/chat_model.dart';

class SQLManager {
  static const String DATABASE_NAME = "socket_chat.db";
  static const String TABLE_MESSAGES = "tbl_messages";
  static const String TABLE_USER_STATUS = "tbl_user_status";
  Database? db;

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, DATABASE_NAME);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        this.db = db;
        await db.execute("""CREATE TABLE $TABLE_MESSAGES(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          message TEXT,
          userId TEXT,
          senderId TEXT,
          messageStatus TEXT,
          messageId INT,
          date TEXT,
          attachment TEXT
        )""");

        await db.execute("""CREATE TABLE $TABLE_USER_STATUS(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          status TEXT,
          userId TEXT
        )""");
      },
    );
  }

  Future<int> addMessage(ChatModel message) async {
    db = await init();

    return await db!.insert(TABLE_MESSAGES, message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<ChatModel>> getMessages(
      String userId, String otherUserId, int page) async {
    db = await init();

   /* final maps = await db!.query(
      TABLE_MESSAGES,
      limit: 20,
      offset: page == 1 ? 0 : ((page - 1) * 20),
      orderBy: "date",
    );*/

    final maps = await db!.rawQuery("""
    SELECT * FROM (SELECT * FROM $TABLE_MESSAGES ORDER BY id DESC LIMIT 20 OFFSET ${page == 1 ? 0 : ((page - 1) * 20)})
    ORDER BY id ASC 
    """);

    return List.generate(maps.length, (i) {
      Map<String, dynamic> obj = maps[i];
      return ChatModel(
        messageId: obj['messageId'],
        attachment: obj['attachment'],
        message: obj['message'],
        date: obj['date'],
        messageStatus: obj['messageStatus'],
        userId: obj['userId'],
        senderId: obj['senderId'],
        isAttchmentUploading: false,
      );
    });
  }

  Future<int> updateMessage(ChatModel chatModel) async {
    db = await init();

    return db!.update(TABLE_MESSAGES, chatModel.toMap(),
        where: "messageId=?", whereArgs: [chatModel.messageId]);
  }

  Future<int> updateAllMessagesStatus(String messageStatus) async {
    db = await init();

    return await db!.update(TABLE_MESSAGES, {'messageStatus': messageStatus});
  }

  Future<int> updateMessageStatus(
      String messageStatus, String messageId) async {
    db = await init();

    return await db!.update(TABLE_MESSAGES, {'messageStatus': messageStatus},
        where: "messageId=?", whereArgs: [messageId]);
  }

  Future<int> updateMessagesSentToSeen(String userId, String status) async {
    db = await init();

    return await db!.update(TABLE_MESSAGES, {'messageStatus': status},
        where: "userId=? AND messageStatus=?", whereArgs: [userId, status]);
  }

  Future<int> updateUserStatus(String userId, String status) async {
    db = await init();

    final map = await db!
        .query(TABLE_USER_STATUS, where: "userId=?", whereArgs: [userId]);
    if (map.isNotEmpty) {
      return await db!.update(
          TABLE_USER_STATUS, {'status': status, 'userId': userId},
          where: "userId=?", whereArgs: [userId]);
    } else {
      return await db!.insert(
        TABLE_USER_STATUS,
        {'status': status, 'userId': userId},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<String> getUserStatus(String userId) async {
    db = await init();

    final map = await db!
        .query(TABLE_USER_STATUS, where: "userId=?", whereArgs: [userId]);
    return map != null && map.isNotEmpty
        ? map[0]['status'].toString()
        : SignalingConstants.offline;
  }

  Future<int> getMessagesCount(String userId, String otherUserId) async {
    db = await init();
    return Sqflite.firstIntValue(await db!.rawQuery(
        'SELECT COUNT(*) FROM $TABLE_MESSAGES'))!;
  }
}
