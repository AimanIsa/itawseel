import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/pages/Customer/chatscreen.dart';
import 'package:itawseel/themes/colors.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String currentUserId;
  late String chatId;
  late String recipientId;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser!.email!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 30),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final user = snapshot.data!.docs[index];
                      final userId = user.id;

                      if (userId != currentUserId) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Card(
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 25.0,
                                      backgroundColor: Colors.grey,
                                      backgroundImage:
                                          user['imageUrl'] != 'default' &&
                                                  user['imageUrl'].isNotEmpty
                                              ? NetworkImage(user['imageUrl'])
                                              : NetworkImage(user['imageUrl']),
                                    ),
                                    title: Text(
                                      user['username'],
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(user['email']),
                                    onTap: () async {
                                      chatId = getChatId(currentUserId, userId);
                                      recipientId = userId;
                                      await _firestore
                                          .collection('chats')
                                          .doc(chatId)
                                          .set({
                                        'users': [currentUserId, userId]
                                      });
                                      // ignore: use_build_context_synchronously
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(
                                            chatId: chatId,
                                            recipientId: recipientId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 7),
                            ],
                          ),
                        );
                      } else {
                        return const SizedBox.shrink(); // Hide current user
                      }
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  String getChatId(String user1, String user2) {
    if (user1.compareTo(user2) < 0) {
      return '$user1-$user2';
    } else {
      return '$user2-$user1';
    }
  }
}
