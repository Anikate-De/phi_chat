class Message {
  String? text;
  String sender;
  bool isCurrentUser;
  String? hour;
  String? minute;
  bool isClosing;
  bool isOnNewDate;
  DateTime newDate;
  String? pfp;
  bool showSender;
  bool isReplying;
  String? replySender;
  String? replyText;
  bool isMedia;
  String? mediaURL;

  Message({
    this.text,
    required this.sender,
    this.isCurrentUser = false,
    this.hour,
    this.minute,
    this.isClosing = true,
    this.isOnNewDate = false,
    required this.newDate,
    this.pfp,
    this.showSender = false,
    this.isReplying = false,
    this.replySender,
    this.replyText,
    this.isMedia = false,
    this.mediaURL,
  });
}
