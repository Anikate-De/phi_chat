import 'package:phi_chat/screens/conversations_screen.dart';
import 'package:phi_chat/screens/forgot_password_screen.dart';
import 'package:phi_chat/screens/registration_screen.dart';
import 'package:phi_chat/screens/user_settings_screen.dart';
import 'package:phi_chat/screens/verification_screen.dart';
import 'package:phi_chat/widgets/rounded_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 44),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 60,
                      ),
                      const Icon(
                        Icons.motion_photos_off_rounded,
                        size: 85,
                        color: Colors.blue,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Hello Again!',
                        style: TextStyle(
                            fontFamily: 'Handlee',
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            letterSpacing: 1,
                            wordSpacing: 2,
                            color: Colors.blue),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Welcome back, you\'ve been missed',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Handlee',
                              fontSize: 18,
                              letterSpacing: 0.4,
                              wordSpacing: 2,
                              color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
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
                        height: 8,
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, ForgotPasswordScreen.id);
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                                fontFamily: 'Handlee',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                letterSpacing: 0.8,
                                wordSpacing: 2,
                                color: Colors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 28,
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
                                await auth.signInWithEmailAndPassword(
                                    email: _email.trim(), password: _password);
                              } on FirebaseAuthException catch (e) {
                                setState(() => _isLoading = false);
                                if (e.code == 'user-not-found') {
                                  setState(() {
                                    _passwordError = false;
                                    _emailError = true;
                                    _emailErrorText = 'Not Found';
                                  });
                                } else if (e.code == 'wrong-password') {
                                  setState(() {
                                    _emailError = false;
                                    _passwordError = true;
                                    _passwordErrorText = 'Incorrect Password';
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
                                              (Route<dynamic> route) => false);
                                    } else {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              UserSettingsScreen.id,
                                              (Route<dynamic> route) => false);
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
                            'Sign In',
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(
                                  color: Colors.grey[500],
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
                        width: double.infinity,
                        height: 56,
                        child: TextButton(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            flag = false;

                            try {
                              GoogleSignIn googleSignIn = GoogleSignIn();

                              GoogleSignInAccount? googleSignInAccount;
                              googleSignInAccount = await googleSignIn.signIn();
                              final GoogleSignInAuthentication
                                  googleSignInAuthentication =
                                  await googleSignInAccount!.authentication;

                              final AuthCredential credential =
                                  GoogleAuthProvider.credential(
                                accessToken:
                                    googleSignInAuthentication.accessToken,
                                idToken: googleSignInAuthentication.idToken,
                              );

                              await auth.signInWithCredential(credential);
                            } on FirebaseAuthException catch (e) {
                              setState(() => _isLoading = false);
                              flag = true;
                              if (e.code ==
                                  'account-exists-with-different-credential') {
                                showSnackBar(
                                    'Account already exists with different credentials, please try again.');
                              } else if (e.code == 'invalid-credential') {
                                showSnackBar(
                                    'Invalid credentials, please try again.');
                              }
                            } on PlatformException {
                              setState(() => _isLoading = false);
                              flag = true;
                            } catch (e) {
                              setState(() => _isLoading = false);
                              flag = true;
                              showSnackBar(
                                  'We ran into an error, please try again later.');
                            }

                            if (!flag) {
                              setState(() => _isLoading = false);
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.email)
                                  .get()
                                  .then((DocumentSnapshot snapshot) {
                                if (snapshot.exists) {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      ConversationsScreen.id,
                                      (Route<dynamic> route) => false);
                                } else {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      UserSettingsScreen.id,
                                      (Route<dynamic> route) => false);
                                }
                              });
                            }
                          },
                          style: ButtonStyle(
                              overlayColor:
                                  MaterialStateProperty.all(Colors.grey[400]),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.grey[300]),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(40)))),
                          child: Row(
                            children: [
                              Container(
                                height: double.infinity,
                                width: 46,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/icons8-google.svg',
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 46),
                                  child: Text(
                                    'Sign In With Google',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[700],
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
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, RegisrationScreen.id);
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'New here? ',
                                style: TextStyle(
                                  fontFamily: 'Handlee',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  wordSpacing: 2,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const Text(
                                'Register Now',
                                style: TextStyle(
                                  fontFamily: 'Handlee',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  wordSpacing: 2,
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue,
                                ),
                              ),
                            ]),
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
                      ),
                    ],
                  ),
                ),
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
