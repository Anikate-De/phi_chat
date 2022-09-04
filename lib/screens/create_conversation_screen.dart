import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/loading_overlay.dart';
import 'conversations_screen.dart';

class CreateConversationScreen extends StatefulWidget {
  const CreateConversationScreen({Key? key}) : super(key: key);

  static const String id = 'create_conversation';

  @override
  State<CreateConversationScreen> createState() =>
      _CreateConversationScreenState();
}

class _CreateConversationScreenState extends State<CreateConversationScreen> {
  String? convoName;
  String convoUsers = '';
  String url = '';

  bool _isAvatarLoading = false;

  int _counter = 30;
  bool _isLoading = false;

  XFile? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 54, vertical: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Bring your loved ones here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Handlee',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.blue),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        setState(() {
                          imageFile = pickedFile;
                          _isAvatarLoading = true;
                        });
                        final storage = FirebaseStorage.instance;
                        final storageRef = storage.ref();
                        final imageRef = storageRef.child(
                            "conversation_photos/${FirebaseAuth.instance.currentUser!.email! + DateTime.now().millisecondsSinceEpoch.toString()}.jpg");
                        imageRef
                            .putFile(File(imageFile!.path))
                            .snapshotEvents
                            .listen((taskSnapshot) async {
                          switch (taskSnapshot.state) {
                            case TaskState.paused:
                              break;
                            case TaskState.success:
                              url = await imageRef.getDownloadURL();
                              setState(() => _isAvatarLoading = false);
                              break;
                            case TaskState.canceled:
                              setState(() {
                                imageFile = null;
                                _isAvatarLoading = false;
                              });
                              break;
                            case TaskState.error:
                              setState(() {
                                imageFile = null;

                                _isAvatarLoading = false;
                              });
                              break;
                            case TaskState.running:
                              break;
                          }
                        });
                      },
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 6, right: 6, left: 6),
                            child: LoadingOverlay(
                              isLoading: _isAvatarLoading,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: imageFile != null
                                    ? FileImage(File(imageFile!.path))
                                    : null,
                                backgroundColor: Colors.grey[400],
                                child: imageFile != null
                                    ? null
                                    : Icon(
                                        Icons.groups_rounded,
                                        color: Colors.grey[200],
                                        size: 60,
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                  shape: BoxShape.circle,
                                  color: Colors.blue),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: Colors.grey[600]),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Text(
                            'This will be the conversation\'s picture. It\'s best to put an image the other members will quickly recognise',
                            style: TextStyle(
                                fontFamily: 'Handlee',
                                letterSpacing: .6,
                                color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 90,
                      child: TextField(
                        style: const TextStyle(
                            fontFamily: 'Handlee',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 2),
                        onChanged: (text) {
                          if (text.trim().isEmpty) {
                            convoName = null;
                          } else {
                            convoName = text.trim();
                          }
                          if (text.length <= 30) {
                            setState(() {
                              _counter = 30 - text.length;
                            });
                          }
                        },
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: [LengthLimitingTextInputFormatter(30)],
                        decoration: InputDecoration(
                          counterText: _counter.toString(),
                          counterStyle: const TextStyle(
                              fontFamily: 'Handlee',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40)),
                          enabled: true,
                          labelText: 'Conversation Name',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: Colors.grey[600]),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Text(
                            'The Conversation name will be visible to all members, make it catchy so that people remember it!',
                            style: TextStyle(
                                fontFamily: 'Handlee',
                                letterSpacing: .6,
                                color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 90,
                      child: TextField(
                        style: const TextStyle(
                            fontFamily: 'Handlee',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 2),
                        onChanged: (text) {
                          if (text.trim().isEmpty) {
                            convoUsers = '';
                          } else {
                            convoUsers = text.trim();
                          }
                        },
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40)),
                          enabled: true,
                          labelText: 'Add Members Here',
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: Colors.grey[600]),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Text(
                            'Mention your members\' email id\'s by putting a comma (,) in between.\nLike this - a@mail.com,b@mail.com,c@mail.com,d....',
                            style: TextStyle(
                                fontFamily: 'Handlee',
                                letterSpacing: .6,
                                color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                            overlayColor:
                                MaterialStateProperty.all(Colors.white24),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40)))),
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          try {
                            FirebaseAuth auth = FirebaseAuth.instance;
                            if (auth.currentUser != null) {
                              dynamic users = convoUsers.split(',').toList() +
                                  [FirebaseAuth.instance.currentUser!.email!];
                              users.removeWhere(
                                  (element) => element.toString().isEmpty);
                              users.map((e) => e.trim()).toList();
                              log(users.toString());
                              var convoDocRef = FirebaseFirestore.instance
                                  .collection('conversations')
                                  .doc();
                              convoDocRef.set({
                                'name': convoName,
                                'photo': url,
                                'users': users,
                              });
                              for (var user in users) {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user)
                                    .update({
                                  'conversations':
                                      FieldValue.arrayUnion([convoDocRef.id])
                                });
                              }
                              Navigator.pushNamedAndRemoveUntil(context,
                                  ConversationsScreen.id, (route) => false);
                            }
                            setState(() => _isLoading = false);
                          } catch (e) {
                            log(e.toString());
                            setState(() => _isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'We ran into an error, please try again later',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Text(
                          'Create',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Handlee',
                              fontSize: 16,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold),
                        ),
                        label: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
