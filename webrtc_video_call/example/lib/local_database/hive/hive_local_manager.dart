import 'package:hive/hive.dart';

import '../../database/database_constants.dart';

class HiveLocalManager {
  bool hiveEnabled = false;

  late Box boxChatMessages;
  late Box<String> boxUserStatus;

  Future<bool> init() async {
    hiveEnabled = false;
    boxChatMessages = await Hive.openBox(DatabaseConstants.chat_message_table);
    boxUserStatus = await Hive.openBox<String>(DatabaseConstants.user_status);
    return false;
  }

  void putChatMessages(String key, dynamic value) {
    if(hiveEnabled) {
      boxChatMessages.put(key, value);
    }
  }

  dynamic getChatMessages(String key, {defaultValue}) {
    if(!hiveEnabled){
      return [];
    }
    return boxChatMessages.get(key,defaultValue: defaultValue);
  }

  void putUserStatus(String key, dynamic value){
    if(!hiveEnabled){
      return;
    }
    boxUserStatus.put(key, value);
  }

  dynamic getUserStatus(String key, {defaultValue}){
    if(!hiveEnabled){
      return "";
    }
    return boxUserStatus.get(key,defaultValue: defaultValue);
  }
}
