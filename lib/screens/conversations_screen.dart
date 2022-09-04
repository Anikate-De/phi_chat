import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:phi_chat/screens/chat_screen.dart';
import 'package:phi_chat/screens/create_conversation_screen.dart';
import 'package:phi_chat/screens/join_conversation_screen.dart';
import 'package:phi_chat/screens/share_conversation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../models/conversation_model.dart';
import 'login_screen.dart';

class ConversationsScreen extends StatefulWidget {
  static String id = 'conversations';

  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? user;

  Set<String> usersInteractedWith = <String>{};

  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  Future<void> loadPrefsInstance() async {
    prefs = await SharedPreferences.getInstance();
  }

  final Map<String, Map> emailToPFP = <String, Map>{};

  Future<List<Conversation>> getConversations(List<dynamic> convoIDs) async {
    List<Conversation> conversations = [];
    for (var id in convoIDs) {
      await _firestore
          .collection('conversations')
          .doc(id)
          .get()
          .then((snapshot) {
        conversations.add(
          Conversation(
            id: id,
            name: snapshot.get('name'),
            users: snapshot.get('users'),
            photo: snapshot.get('photo'),
          ),
        );
        for (var friend in snapshot.get('users')) {
          usersInteractedWith.add(friend);
        }
      });
    }
    if (prefs == null) {
      await loadPrefsInstance();
    }
    await getUsersPFP();
    return conversations;
  }

  getUsersPFP() async {
    for (var friend in usersInteractedWith) {
      await _firestore
          .collection('users')
          .doc(friend)
          .get()
          .then((DocumentSnapshot snapshot) {
        emailToPFP[friend] = {
          'profile_photo': snapshot.get('profile_photo'),
          'username': snapshot.get('username')
        };
      });
    }
    await addToPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Conversations',
          style: TextStyle(
              fontFamily: 'Handlee',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _auth.signOut();
              GoogleSignIn().signOut();
              Navigator.pushReplacementNamed(context, LoginScreen.id);
            },
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(
                Icons.logout,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, JoinConversationScreen.id);
          setState(() {});
        },
        label: const Text('Join'),
        icon: const Icon(Icons.group_add_rounded),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: StreamBuilder<DocumentSnapshot>(
            stream: provideDocumentFieldStream(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> documentFields =
                    snapshot.data!.data() as Map<String, dynamic>;
                return Column(
                  children: [
                    ListTile(
                      isThreeLine: false,
                      dense: false,
                      onTap: () {
                        Navigator.pushNamed(
                            context, CreateConversationScreen.id);
                      },
                      leading: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const ClipOval(
                            child: Icon(
                              Icons.group_add_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Create a new conversation',
                            style: TextStyle(
                                fontFamily: 'Handlee',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                      subtitle: const Text(
                        'Click here to start inviting people',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Handlee',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder(
                        future:
                            getConversations(documentFields['conversations']),
                        builder: ((context,
                            AsyncSnapshot<List<Conversation>>
                                snapshotListConvos) {
                          if (snapshotListConvos.connectionState ==
                              ConnectionState.done) {
                            if (snapshotListConvos.hasData) {
                              if (snapshotListConvos.data!.isEmpty) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        'It feels so empty here...\nStart by creating or joining a conversation',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Handlee',
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.6,
                                            color: Colors.grey.shade600),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: ListView.builder(
                                  itemCount: snapshotListConvos.data!.length,
                                  itemBuilder: (context, index) {
                                    List<dynamic> convoUsers =
                                        snapshotListConvos.data!
                                            .elementAt(index)
                                            .users;
                                    for (int i = 0;
                                        i < convoUsers.length;
                                        i++) {
                                      if (emailToPFP
                                          .containsKey(convoUsers[i])) {
                                        convoUsers[i] = emailToPFP[
                                            convoUsers[i]]!['username'];
                                      }
                                    }
                                    convoUsers.sort();
                                    String photo = snapshotListConvos.data!
                                        .elementAt(index)
                                        .photo;
                                    return ListTile(
                                      isThreeLine: false,
                                      dense: false,
                                      onTap: () => Navigator.pushNamed(
                                          context, ChatScreen.id,
                                          arguments: snapshotListConvos.data!
                                              .elementAt(index)),
                                      leading: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade400,
                                            shape: BoxShape.circle,
                                          ),
                                          child: ClipOval(
                                            child: photo.isNotEmpty
                                                ? CachedNetworkImage(
                                                    maxHeightDiskCache: 50,
                                                    imageUrl: photo,
                                                    placeholder:
                                                        (context, url) {
                                                      return Icon(
                                                        Icons.person_rounded,
                                                        color: Colors
                                                            .grey.shade200,
                                                        size: 28,
                                                      );
                                                    },
                                                    errorWidget:
                                                        (context, url, error) {
                                                      return Icon(
                                                        Icons
                                                            .people_alt_rounded,
                                                        color: Colors
                                                            .grey.shade200,
                                                        size: 28,
                                                      );
                                                    },
                                                  )
                                                : Icon(
                                                    Icons.people_alt_rounded,
                                                    color: Colors.grey.shade200,
                                                    size: 28,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      title: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            snapshotListConvos.data!
                                                .elementAt(index)
                                                .name,
                                            style: const TextStyle(
                                                fontFamily: 'Handlee',
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1),
                                          ),
                                          // Text(
                                          //   '88:88 pm',
                                          //   textScaleFactor: 0.75,
                                          //   style: TextStyle(
                                          //       fontFamily: 'Handlee',
                                          //       fontWeight: FontWeight.bold,
                                          //       color: Colors.grey.shade600,
                                          //       letterSpacing: 1.2),
                                          // ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        convoUsers
                                            .join(', ')
                                            .replaceAll('', '\u200B'),
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Handlee',
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context,
                                              ShareConversationScreen.id,
                                              arguments: snapshotListConvos
                                                  .data!
                                                  .elementAt(index));
                                        },
                                        icon: const Icon(Icons.share),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                enabled: true,
                                child: ListView.builder(
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 24, right: 40),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: 48.0,
                                          height: 48.0,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                width: double.infinity,
                                                height: 16.0,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(
                                                height: 12,
                                              ),
                                              Container(
                                                width: double.infinity,
                                                height: 12.0,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  itemCount:
                                      documentFields['conversations'].length,
                                ),
                              ),
                            );
                          }
                        }),
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            }),
        //   child: ,
      ),
    );
  }

  Stream<DocumentSnapshot> provideDocumentFieldStream() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.email)
        .snapshots();
  }

  Future<void> addToPrefs() async {
    if (prefs == null) {
      await loadPrefsInstance();
    }
    await prefs!.setString('users', jsonEncode(emailToPFP));
  }
}
