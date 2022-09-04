import 'package:phi_chat/models/conversation_model.dart';
import 'package:phi_chat/screens/chat_screen.dart';
import 'package:phi_chat/screens/conversations_screen.dart';
import 'package:phi_chat/screens/create_conversation_screen.dart';
import 'package:phi_chat/screens/edit_media_screen.dart';
import 'package:phi_chat/screens/forgot_password_screen.dart';
import 'package:phi_chat/screens/join_conversation_screen.dart';
import 'package:phi_chat/screens/login_screen.dart';
import 'package:phi_chat/screens/share_conversation_screen.dart';
import 'package:phi_chat/screens/registration_screen.dart';
import 'package:phi_chat/screens/scanner_screen.dart';
import 'package:phi_chat/screens/user_settings_screen.dart';
import 'package:phi_chat/screens/verification_screen.dart';
import 'package:phi_chat/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        ForgotPasswordScreen.id: (context) => const ForgotPasswordScreen(),
        RegisrationScreen.id: (context) => const RegisrationScreen(),
        VerificationScreen.id: (context) => const VerificationScreen(),
        UserSettingsScreen.id: (context) => const UserSettingsScreen(),
        ConversationsScreen.id: (context) => const ConversationsScreen(),
        CreateConversationScreen.id: (context) =>
            const CreateConversationScreen(),
        ShareConversationScreen.id: (context) => ShareConversationScreen(
            ModalRoute.of(context)!.settings.arguments as Conversation),
        JoinConversationScreen.id: (context) => const JoinConversationScreen(),
        ScannerScreen.id: (context) => const ScannerScreen(),
        ChatScreen.id: (context) => ChatScreen(
            ModalRoute.of(context)!.settings.arguments as Conversation),
        EditMediaScreen.id: (context) => EditMediaScreen(
            messageText: (ModalRoute.of(context)!.settings.arguments as List)[0]
                as String,
            imageFile: (ModalRoute.of(context)!.settings.arguments as List)[1]
                as XFile?),
      },
    ),
  );
}
