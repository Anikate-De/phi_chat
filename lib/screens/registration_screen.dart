import 'package:phi_chat/screens/conversations_screen.dart';
import 'package:phi_chat/screens/user_settings_screen.dart';
import 'package:phi_chat/screens/verification_screen.dart';
import 'package:phi_chat/widgets/loading_overlay.dart';
import 'package:phi_chat/widgets/rounded_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisrationScreen extends StatefulWidget {
  static String id = 'registration';

  const RegisrationScreen({Key? key}) : super(key: key);

  @override
  State<RegisrationScreen> createState() => _RegisrationScreenState();
}

class _RegisrationScreenState extends State<RegisrationScreen> {
  late FirebaseAuth auth;
  bool flag = false;

  String _email = '';
  String _password = '';
  bool _emailError = false;
  bool _passwordError = false;
  String _emailErrorText = 'Not Found';
  String _passwordErrorText = 'Incorrect Password';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue,
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50)),
                    ),
                    child: Column(children: [
                      const SizedBox(
                        height: 60,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.motion_photos_off_rounded,
                            size: 85,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Phi Chat',
                            style: TextStyle(
                                fontFamily: 'Pacifico',
                                fontSize: 60,
                                color: Colors.white),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Divider(
                          thickness: 1,
                          color: Colors.white24,
                        ),
                      ),
                      const SizedBox(
                        height: 26,
                      ),
                      Text(
                        'Register Now',
                        style: TextStyle(
                            fontFamily: 'Handlee',
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            letterSpacing: 1,
                            wordSpacing: 2,
                            color: Colors.blue[50]),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                    ]),
                  ),
                  const SizedBox(
                    height: 56,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 46),
                    child: Column(
                      children: [
                        RoundedTextField(
                          onChanged: (text) {
                            _email = text;
                          },
                          error: _emailError,
                          errorText: _emailErrorText,
                          obscure: false,
                          labelText: 'Email ID',
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        RoundedTextField(
                          onChanged: (text) {
                            _password = text;
                          },
                          error: _passwordError,
                          errorText: _passwordErrorText,
                          obscure: true,
                          labelText: 'Password',
                        ),
                        const SizedBox(
                          height: 48,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: TextButton(
                            onPressed: () async {
                              if (_email.isEmpty) {
                                setState(() {
                                  _emailErrorText = '';
                                  _emailError = true;
                                });
                              }
                              if (_password.isEmpty) {
                                setState(() {
                                  _passwordErrorText = '';
                                  _passwordError = true;
                                });
                              }

                              if (_email.isNotEmpty && _password.isNotEmpty) {
                                setState(() => _isLoading = true);
                                try {
                                  flag = false;
                                  await auth.createUserWithEmailAndPassword(
                                      email: _email.trim(),
                                      password: _password);
                                } on FirebaseAuthException catch (e) {
                                  setState(() => _isLoading = false);
                                  if (e.code == 'weak-password') {
                                    setState(() {
                                      _passwordErrorText = 'Too weak';
                                      _passwordError = true;
                                      _emailError = false;
                                    });
                                  } else if (e.code == 'email-already-in-use') {
                                    setState(() {
                                      _emailError = true;
                                      _emailErrorText = 'Already in use';
                                      _passwordError = false;
                                    });
                                  } else if (e.code == 'invalid-email') {
                                    setState(() {
                                      _emailError = true;
                                      _passwordError = false;
                                      _emailErrorText = 'Invalid Email';
                                    });
                                  }
                                  flag = true;
                                } catch (e) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'We ran into an error. Please try again later...',
                                      ),
                                    ),
                                  );
                                  flag = true;
                                }

                                if (!flag) {
                                  setState(() => _isLoading = false);
                                  User? user = auth.currentUser;
                                  if (user != null && !user.emailVerified) {
                                    await user.sendEmailVerification();

                                    Navigator.pushNamed(
                                        context, VerificationScreen.id);
                                  } else {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user!.email)
                                        .get()
                                        .then((DocumentSnapshot snapshot) {
                                      if (snapshot.exists) {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                ConversationsScreen.id,
                                                (Route<dynamic> route) =>
                                                    false);
                                      } else {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                UserSettingsScreen.id,
                                                (Route<dynamic> route) =>
                                                    false);
                                      }
                                    });
                                  }
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please fill up all the fields and try again.',
                                    ),
                                  ),
                                );
                              }

                              // /////
                            },
                            style: ButtonStyle(
                                overlayColor:
                                    MaterialStateProperty.all(Colors.white24),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40)))),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Handlee',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                wordSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
        ),
      ),
    );
  }
}
