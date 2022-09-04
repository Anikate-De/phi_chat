import 'package:phi_chat/screens/scanner_screen.dart';
import 'package:phi_chat/widgets/loading_overlay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JoinConversationScreen extends StatefulWidget {
  static String id = 'join_conversation';

  const JoinConversationScreen({Key? key}) : super(key: key);

  @override
  State<JoinConversationScreen> createState() => _JoinConversationScreenState();
}

class _JoinConversationScreenState extends State<JoinConversationScreen> {
  TextEditingController controller = TextEditingController();
  bool _isLoading = false;

  String? errorText;

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
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 44),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Join a Conversation',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Handlee',
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            fontSize: 30),
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Text(
                      'Found people you know on Phi Chat?\nJoin them in the fun!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Handlee',
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 120,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: TextButton(
                        onPressed: () async {
                          controller.clear();
                          String code = await Navigator.pushNamed(
                              context, ScannerScreen.id) as String;
                          controller.text = code;
                          joinConversation(code);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.qr_code_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              'Scan QR Code',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Handlee',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                wordSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.all(Colors.white24),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Divider(
                                  thickness: 1, color: Colors.grey[400])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: 'Handlee',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Divider(
                                  thickness: 1, color: Colors.grey[400])),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 84,
                      child: TextField(
                        controller: controller,
                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
                        style: const TextStyle(
                            fontFamily: 'Handlee',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 2),
                        onChanged: (value) {
                          if (value.length == 20) {
                            joinConversation(value);
                          }
                          setState(() {
                            errorText = null;
                          });
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          errorText: errorText,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40)),
                          enabled: true,
                          labelText: 'Conversation ID',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Have an ID?\nEnter it in the field above',
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
                      height: 36,
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

  void joinConversation(String code) {
    _isLoading = true;
    FirebaseFirestore.instance
        .collection('conversations')
        .doc(code)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        FirebaseFirestore.instance
            .collection('conversations')
            .doc(code)
            .update({
          'users':
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.email])
        });
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          'conversations': FieldValue.arrayUnion([code])
        });
        setState(() {
          errorText = null;
        });
        Navigator.pop(context);
      } else {
        setState(() {
          errorText = 'Invalid Conversation ID';
        });
      }
    });
    _isLoading = false;
  }
}
