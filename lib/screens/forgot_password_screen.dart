import 'package:phi_chat/widgets/loading_overlay.dart';
import 'package:phi_chat/widgets/rounded_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static String id = 'forgot_password';

  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _email = '';
  bool _emailError = false;
  String _emailErrorText = 'Not Found';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            size: 28,
          ),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'Handlee',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
            child: Column(
              children: [
                const Text(
                  'Get an email to reset your account\'s password',
                  style: TextStyle(
                      fontFamily: 'Handlee',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey),
                ),
                const SizedBox(
                  height: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 64.0),
                  child: RoundedTextField(
                    onChanged: (text) {
                      _email = text;
                    },
                    error: _emailError,
                    errorText: _emailErrorText,
                    obscure: false,
                    labelText: 'Email ID',
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Align(
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
                      onPressed: sendPasswordLink,
                      icon: const Icon(
                        Icons.done,
                        color: Colors.white,
                        size: 24,
                      ),
                      label: const Text(
                        'Done',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Handlee',
                            fontSize: 18,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendPasswordLink() async {
    try {
      setState(() => _isLoading = true);
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.trim());
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password Reset E-mail has been sent to ${_email.trim()}',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (e.code == 'user-not-found') {
        setState(() {
          _emailError = true;
          _emailErrorText = 'Not Found';
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          _emailError = true;
          _emailErrorText = 'Invalid E-mail';
        });
      } else {
        setState(() {
          _emailError = true;
          _emailErrorText = e.message ?? '';
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'We ran into an error, please try again later',
          ),
        ),
      );
    }
  }
}
