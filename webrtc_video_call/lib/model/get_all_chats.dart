import 'chat.dart';

class GetAllChatResponse {
  String? type;
  AllChatData? message;

  GetAllChatResponse({this.type, this.message});

  GetAllChatResponse.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    message = json['message'] != null ? AllChatData.fromJson(json['message']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (message != null) {
      data['message'] = message?.toJson();
    }
    return data;
  }
}

class AllChatData {
  String? type;
  ChatData? allChatListData;

  AllChatData({this.type, this.allChatListData});

  AllChatData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    allChatListData = json['data'] != null ? ChatData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (allChatListData != null) {
      data['data'] = allChatListData?.toJson();
    }
    return data;
  }
}
