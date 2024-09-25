class ChatItem {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String sender;
  final String receiver;
  final String contentType;
  final String message;
  final String? fileURL;

  ChatItem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.sender,
    required this.receiver,
    required this.contentType,
    required this.message,
    this.fileURL,
  });

  factory ChatItem.fromJson(val) {
    return ChatItem(
        id: val["ID"],
        createdAt: val["CreatedAt"],
        updatedAt: val["UpdatedAt"],
        deletedAt: val["DeletedAt"],
        sender: val["sender"],
        receiver: val["receiver"],
        contentType: val["contentType"],
        message: val["message"],
        fileURL: val["fileURL"]);
  }
}
