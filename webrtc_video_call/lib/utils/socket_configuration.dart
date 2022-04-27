enum MessageType {
  addUser,
  videoCall,
  chat,
  checkUnReadMessages,
  getAllChats,
  message,
  sendMessage,
  userStatus,
  messageStatus,
  sent,
  delivered,
  received,
  seen,
  typing
}

String messageTypeValue(MessageType messageType) {
  return '$messageType'.split('.').last;
}

MessageType messageType(String s) {
  return MessageType.values.firstWhere((v) => messageTypeValue(v) == s);
}
