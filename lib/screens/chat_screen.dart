import 'dart:convert';

import 'package:phi_chat/models/message_model.dart';
import 'package:phi_chat/screens/edit_media_screen.dart';
import 'package:phi_chat/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversation_model.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat';

  final Conversation conversation;

  const ChatScreen(this.conversation, {Key? key}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late QuerySnapshot messages;
  var messageFieldController = TextEditingController();
  late User? user;
  String? messageText;

  bool sendEnabled = false;
  late Map<String, dynamic> users = {};
  late SharedPreferences prefs;

  var textFocusNode = FocusNode();
  bool _isReplying = false;
  Map? mapp;

  XFile? imageFile;
  String? url;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUserPFPLinks();
  }

  getCurrentUser() async {
    user = _auth.currentUser;
  }

  void addMessage(String text,
      {required bool isMedia, String? mediaURL}) async {
    firestore
        .collection('conversations/${widget.conversation.id}/messages')
        .add({
      'sender': user?.email,
      'text': text,
      'time': FieldValue.serverTimestamp(),
      'isReplying': _isReplying,
      'replySender': mapp != null && mapp!.containsKey('sender') && _isReplying
          ? mapp!['sender']
          : null,
      'replyText': mapp != null && mapp!.containsKey('text') && _isReplying
          ? mapp!['text']
          : null,
      'isMedia': url != null ? isMedia : false,
      'mediaURL': isMedia ? url : null,
    });
  }

  @override
  void dispose() {
    super.dispose();
    messageFieldController.dispose();
    textFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.conversation.name,
          style: const TextStyle(
              fontFamily: 'Handlee',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.4),
        ),
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: StreamBuilder<QuerySnapshot?>(
                    stream: firestore
                        .collection(
                            'conversations/${widget.conversation.id}/messages')
                        .orderBy('time', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      var messages = snapshot.data?.docs.reversed;
                      if (messages != null) {
                        return ListView.builder(
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              String? previousSender;
                              String? currentSender =
                                  messages.elementAt(index).get('sender');
                              String? nextSender;
                              Timestamp? previousTime;
                              if (messages.length - 1 == index) {
                                previousSender = null;
                                previousTime = null;
                              } else {
                                previousSender =
                                    messages.elementAt(index + 1).get('sender');
                                previousTime =
                                    messages.elementAt(index + 1).get('time');
                              }

                              if (index == 0) {
                                nextSender == null;
                              } else {
                                nextSender =
                                    messages.elementAt(index - 1).get('sender');
                              }

                              Timestamp? time =
                                  messages.elementAt(index).get('time');

                              Message message = Message(
                                text: messages.elementAt(index).get('text'),
                                sender: users.containsKey(currentSender)
                                    ? users[currentSender]['username']
                                    : '',
                                isCurrentUser: user?.email ==
                                    messages.elementAt(index).get('sender'),
                                hour: time != null
                                    ? time.toDate().hour.toString()
                                    : DateTime.now().hour.toString(),
                                minute: time != null
                                    ? time.toDate().minute.toString()
                                    : DateTime.now().minute.toString(),
                                isClosing: !(nextSender != null &&
                                    currentSender == nextSender),
                                isOnNewDate: (time != null &&
                                        previousTime != null &&
                                        time.toDate().day -
                                                previousTime.toDate().day >=
                                            1) ||
                                    previousTime == null,
                                newDate: time != null
                                    ? time.toDate()
                                    : DateTime.now(),
                                pfp: users.containsKey(currentSender)
                                    ? users[currentSender]['profile_photo']
                                    : null,
                                showSender: previousSender != null &&
                                        currentSender == previousSender
                                    ? false
                                    : users.containsKey(currentSender)
                                        ? true
                                        : false,
                                isReplying:
                                    messages.elementAt(index).get('isReplying'),
                                replySender: messages
                                    .elementAt(index)
                                    .get('replySender'),
                                replyText:
                                    messages.elementAt(index).get('replyText'),
                                isMedia:
                                    messages.elementAt(index).get('isMedia'),
                                mediaURL:
                                    messages.elementAt(index).get('mediaURL'),
                              );
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: index == 0 ? 12 : 0),
                                child: MessageBubble(
                                    message: message,
                                    replyCallback: (
                                        {required String text,
                                        required String sender}) {
                                      textFocusNode.requestFocus();
                                      setState(() {
                                        _isReplying = true;
                                        mapp = jsonDecode(
                                            '{"sender" : "$sender", "text" : "$text"}');
                                      });
                                    }),
                              );
                            });
                      } else {
                        return Container();
                      }

                      // return ListView(
                      //   padding: const EdgeInsets.all(8.0),
                      //   reverse: true,
                      //   children: messageBubbles,
                      // );
                    },
                  ),
                ),
              ),
              Divider(
                color: Colors.grey[300],
                height: 1.0,
                thickness: 1.2,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _isReplying
                                ? Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: Colors.blue.shade100
                                            .withOpacity(0.45),
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(16))),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                mapp!['sender'],
                                                style: const TextStyle(
                                                  fontFamily: 'Handlee',
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.2,
                                                  color: Colors.blue,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                mapp!['text'],
                                                maxLines: 2,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'Handlee',
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.9,
                                                  color: Colors.grey.shade800,
                                                  fontSize: 13,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => setState(
                                              () => _isReplying = false),
                                          child: Icon(
                                            Icons.close_rounded,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            TextField(
                              focusNode: textFocusNode,
                              autofocus: true,
                              onChanged: (text) {
                                messageText = text;
                                setState(() {
                                  sendEnabled = text.trim().isNotEmpty;
                                });
                              },
                              style: const TextStyle(
                                fontFamily: 'Handlee',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                              controller: messageFieldController,
                              textCapitalization: TextCapitalization.sentences,
                              cursorHeight: 20,
                              maxLines: 4,
                              minLines: 1,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  icon: Transform.rotate(
                                      angle: -45,
                                      child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () async {
                                            final pickedFile =
                                                await ImagePicker().pickImage(
                                              source: ImageSource.gallery,
                                            );
                                            if (pickedFile != null) {
                                              imageFile = pickedFile;
                                              var response =
                                                  await Navigator.pushNamed(
                                                      context,
                                                      EditMediaScreen.id,
                                                      arguments: [
                                                    messageText ?? '',
                                                    imageFile
                                                  ]) as Map;
                                              url = response['url'] != null
                                                  ? response['url'] as String
                                                  : null;

                                              if (url != null) {
                                                addMessage(response['text'],
                                                    isMedia: true,
                                                    mediaURL: url);
                                              }
                                            }
                                          },
                                          child: const Icon(
                                              Icons.attach_file_rounded))),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 12),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40)),
                                  enabled: true,
                                  hintText: 'Message'),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        child: const Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Icon(
                            Icons.send,
                            size: 20,
                          ),
                        ),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            const CircleBorder(side: BorderSide.none),
                          ),
                        ),
                        onPressed: sendEnabled
                            ? () {
                                addMessage(messageText ?? '', isMedia: false);

                                messageFieldController.clear();
                                setState(() {
                                  messageText = '';
                                  sendEnabled = !sendEnabled;
                                  _isReplying = false;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getUserPFPLinks() async {
    prefs = await SharedPreferences.getInstance();
    users = jsonDecode(prefs.getString('users') ?? '');
  }
}
