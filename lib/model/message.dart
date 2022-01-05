class Message {
  final String nickName;
  final String message;

  Message({
    required this.nickName,
    required this.message,
  });

  factory Message.fromJson(dynamic json) {
    return Message(
      nickName: json['nickName'],
      message: json['message'],
    );
  }
}
