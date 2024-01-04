import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/themes/colors.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String recipientId;

  const ChatScreen({
    required this.chatId,
    required this.recipientId,
    Key? key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String currentUserId;

  late TextEditingController _messageController;
  Future<String> getRecipientUsername() async {
    final doc =
        await _firestore.collection('Users').doc(widget.recipientId).get();
    return doc['username'];
  }

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser!.email!;
    _messageController = TextEditingController();

    // Create the chat collection document if it doesn't exist
    _firestore.collection('chats').doc(widget.chatId).set({
      'lastMessage': '',
      'lastMessageSender': '',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        toolbarHeight: 90,
        title: FutureBuilder<String>(
          future: getRecipientUsername(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                snapshot.data!,
                style: TextStyle(color: white),
              );
            } else if (snapshot.hasError) {
              return const Text('Error loading username');
            }
            return const Text('Loading...');
          },
        ),
      ),
      body: Card(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('chats')
              .doc(widget.chatId)
              .collection('messages')
              .orderBy('timestamp', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final message = snapshot.data!.docs[index];
                  final messageText = message['text'];
                  final messageSender = message['sender'];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: messageSender == currentUserId
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (messageSender != currentUserId)
                          const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: messageSender == currentUserId
                                ? Colors.blue[100]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(messageText),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.black87),
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                if (_messageController.text.isNotEmpty) {
                  await _firestore
                      .collection('chats')
                      .doc(widget.chatId)
                      .collection('messages')
                      .add({
                    'sender': currentUserId,
                    'text': _messageController.text,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  // Update the last message details in the chat document
                  await _firestore
                      .collection('chats')
                      .doc(widget.chatId)
                      .update({
                    'lastMessage': _messageController.text,
                    'lastMessageSender': currentUserId,
                    'lastMessageTimestamp': FieldValue.serverTimestamp(),
                  });
                  _messageController.clear();
                }
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
