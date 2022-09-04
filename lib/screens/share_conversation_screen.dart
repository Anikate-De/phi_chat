import 'package:cached_network_image/cached_network_image.dart';
import 'package:phi_chat/models/conversation_model.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

class ShareConversationScreen extends StatelessWidget {
  static String id = 'qr_code';

  final Conversation _conversation;

  const ShareConversationScreen(this._conversation, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      floatingActionButton: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 56, left: 32),
          child: FloatingActionButton.small(
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 22,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 44),
              child: Column(
                children: [
                  DottedBorder(
                    dashPattern: const [20, 4],
                    borderType: BorderType.Circle,
                    color: Colors.blue,
                    strokeWidth: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child:
                              CachedNetworkImage(imageUrl: _conversation.photo),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    Characters(_conversation.name)
                        .replaceAll(Characters(''), Characters('\u{200B}'))
                        .toString(),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Handlee',
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        fontSize: 28),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    'Ask your loved ones to join this conversation!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Handlee',
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Head over to Conversations -> Join',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Handlee',
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  Align(
                    child: Card(
                      elevation: 8,
                      child: QrImage(
                        dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.circle,
                            color: Colors.black),
                        padding: const EdgeInsets.all(16),
                        data: _conversation.id,
                        gapless: false,
                        size: 200,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Scan the QR Code above\nOR\nCopy the ID from below',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Handlee',
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _conversation.id,
                          maxLines: 1,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: _conversation.id));
                            Fluttertoast.showToast(
                              msg: "Copied to clipboard",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.blue,
                            );
                          },
                          color: Colors.grey.shade800,
                          icon: const Icon(
                            Icons.copy_rounded,
                            size: 30,
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
