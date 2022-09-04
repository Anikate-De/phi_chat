import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditMediaScreen extends StatefulWidget {
  static String id = 'edit_media';
  final String messageText;
  final XFile? imageFile;

  const EditMediaScreen({this.messageText = '', this.imageFile, Key? key})
      : super(key: key);

  @override
  State<EditMediaScreen> createState() => _EditMediaScreenState();
}

class _EditMediaScreenState extends State<EditMediaScreen> {
  String? url;

  TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    messageController.text = widget.messageText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context, url),
            child: const Icon(
              Icons.clear_rounded,
              color: Colors.white,
            ),
          )),
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
                child: Image.file(File(widget.imageFile!.path),
                    width: double.infinity)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      // focusNode: textFocusNode,
                      controller: messageController,
                      autofocus: true,
                      onChanged: (text) {},
                      style: const TextStyle(
                        fontFamily: 'Handlee',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      cursorHeight: 20,
                      maxLines: 4,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40)),
                          enabled: true,
                          hintText: 'Message'),
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
                    onPressed: () {
                      final storage = FirebaseStorage.instance;
                      final storageRef = storage.ref();
                      final imageRef = storageRef.child(
                          "conversation_media/${FirebaseAuth.instance.currentUser!.email}" +
                              Random()
                                  .nextInt(1000000000)
                                  .toString()
                                  .padLeft(9, '0'));
                      imageRef
                          .putFile(File(widget.imageFile!.path))
                          .snapshotEvents
                          .listen((taskSnapshot) async {
                        switch (taskSnapshot.state) {
                          case TaskState.paused:
                            break;
                          case TaskState.success:
                            url = await imageRef.getDownloadURL();
                            Navigator.pop(context,
                                {'url': url, 'text': messageController.text});
                            break;
                          case TaskState.canceled:
                            break;
                          case TaskState.error:
                            break;
                          case TaskState.running:
                            break;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
