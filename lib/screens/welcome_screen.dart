import 'package:phi_chat/screens/conversations_screen.dart';
import 'package:phi_chat/screens/login_screen.dart';
import 'package:phi_chat/screens/user_settings_screen.dart';
import 'package:phi_chat/screens/verification_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome';

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    checkUser();
  }

  checkUser() {
    Future.delayed(Duration.zero, () {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (!user.emailVerified) {
          Navigator.pushReplacementNamed(context, VerificationScreen.id);
        } else {
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.email)
              .get()
              .then((DocumentSnapshot snapshot) {
            if (snapshot.exists) {
              Navigator.pushReplacementNamed(context, ConversationsScreen.id);
            } else {
              Navigator.pushReplacementNamed(context, UserSettingsScreen.id);
            }
          });
        }
      } else {
        Navigator.pushReplacementNamed(context, LoginScreen.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.motion_photos_off_rounded,
                          size: 160,
                          color: Colors.blue,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Phi Chat',
                          style: TextStyle(
                              fontFamily: 'Pacifico',
                              fontSize: 50,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: SizedBox(
                        child: Text(
                          'Phi Chat v1.0.1',
                          style: TextStyle(
                              fontFamily: 'Pacifico',
                              fontSize: 18,
                              letterSpacing: 1.2,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
