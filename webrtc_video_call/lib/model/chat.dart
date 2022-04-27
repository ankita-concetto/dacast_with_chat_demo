enum MessageStatus { sent, delivered, seen, received }

class ChatData {
  int? totalData;
  int? totalPage;
  int? currentPage;
  int? dataPerPage;
  List<Chat>? data;

  ChatData({this.totalData, this.totalPage, this.currentPage, this.dataPerPage, this.data});

  ChatData.fromJson(Map<String, dynamic> json) {
    totalData = json['total_data'];
    totalPage = json['total_page'];
    currentPage = json['current_page'];
    dataPerPage = json['data_per_page'];
    if (json['data'] != null) {
      data = <Chat>[];
      json['data'].forEach((v) {
        data?.add(Chat.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_data'] = totalData;
    data['total_page'] = totalPage;
    data['current_page'] = currentPage;
    data['data_per_page'] = dataPerPage;
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Chat {
  int? id;
  int? fromUserId;
  int? toUserId;
  String? message;
  String? type;
  int? status;
  int? createdAt;
  int? time;
  int? updatedAt;
  int? entityTypeId;
  int? entityId;
  int? isDefaultMessage; //is_default_message

  Chat(
      {this.id,
      this.fromUserId,
      this.toUserId,
      this.message,
      this.type,
      this.status,
      this.entityTypeId,
      this.entityId,
      this.time,
      this.createdAt,
      this.updatedAt,
      this.isDefaultMessage});

  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fromUserId = json['from_user_id'];
    toUserId = json['to_user_id'];
    message = json['message'];
    type = json['type'];
    status = json['status'];
    entityTypeId = json['entity_type_id'];
    entityId = json['entity_id'];
    time = json['time'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isDefaultMessage = json['is_default_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['from_user_id'] = fromUserId;
    data['to_user_id'] = toUserId;
    data['message'] = message;
    data['type'] = type;
    data['status'] = status;
    data['entity_type_id'] = entityTypeId;
    data['entity_id'] = entityId;
    data['time'] = time;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_default_message'] = updatedAt;
    return data;
  }
}
