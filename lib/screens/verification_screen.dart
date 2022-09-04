import 'package:phi_chat/screens/conversations_screen.dart';
import 'package:phi_chat/screens/user_settings_screen.dart';
import 'package:phi_chat/widgets/loading_overlay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  static String id = 'verification';

  const VerificationScreen({Key? key}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  void verify() async {
    if (_user != null) {
      setState(() => _isLoading = true);
      await _user!.reload();
      _user = _auth.currentUser;
      bool verified = _user!.emailVerified;
      setState(() => _isLoading = false);
      if (verified) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.email)
            .get()
            .then((DocumentSnapshot snapshot) {
          if (snapshot.exists) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                ConversationsScreen.id, (Route<dynamic> route) => false);
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
                UserSettingsScreen.id, (Route<dynamic> route) => false);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please complete verification first, and try again',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(46),
                          topRight: Radius.circular(30))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Wait Wait Wait!',
                            style: TextStyle(
                                fontFamily: 'Handlee',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Icon(
                            Icons.back_hand_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "We've sent you an email to\n",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  fontFamily: 'Handlee'),
                            ),
                            TextSpan(
                                text: "Verify Your Email ID",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 26,
                                    letterSpacing: 1.4,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Handlee')),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      const Text(
                        'Click on the verification link sent to your Email ID',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            fontFamily: 'Handlee'),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        _user!.email ?? '',
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 24,
                            decoration: TextDecoration.underline,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Handlee'),
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'Once done, click "Verify"',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                  fontFamily: 'Handlee'),
                            ),
                          ),
                          TextButton.icon(
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
                                          borderRadius:
                                              BorderRadius.circular(40)))),
                              onPressed: verify,
                              icon: const Icon(
                                Icons.done,
                                color: Colors.white,
                                size: 24,
                              ),
                              label: const Text(
                                'Verified',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Handlee',
                                    fontSize: 18,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
