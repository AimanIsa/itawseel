import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/themes/colors.dart';

class ChatScreenAdminPage extends StatefulWidget {
  final String chatId;
  final String recipientId;

  const ChatScreenAdminPage({
    required this.chatId,
    required this.recipientId,
    Key? key,
  }) : super(key: key);

  @override
  _ChatScreenAdminPageState createState() => _ChatScreenAdminPageState();
}

class _ChatScreenAdminPageState extends State<ChatScreenAdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String currentUserId;
  late DocumentReference _chatDocRef;
  late TextEditingController _messageController;
  Future<String> getRecipientUsername() async {
    final doc =
        await _firestore.collection('Users').doc(widget.recipientId).get();
    return doc['username'];
  }

  @override
  void initState() {
    super.initState();
    currentUserId = 'admin123@gmail.com';
    _messageController = TextEditingController();
    _chatDocRef = _firestore.collection('chats').doc(widget.chatId);
    _firestore
        .collection('chats')
        .doc(widget.chatId)
        .set({
          'latestMessage': {}, // Initialize with an empty map
          'receiver': widget.recipientId,
        }, SetOptions(merge: true)) // Merge with existing data
        .then((value) => print('Latest message and receiver initialized'))
        .catchError((error) => print('Error initializing: $error'));
    // Initialize latest message and receiver in the chat document
    initializeLatestMessage();
  }

  void initializeLatestMessage() async {
    await _firestore.collection('chats').doc(widget.chatId).set({
      'latestMessage': '',
      'receiver': widget.recipientId,
    }, SetOptions(merge: true));
  }

  Future<void> updateLatestMessage(String messageText) async {
    await _chatDocRef.update({
      'latestMessage': messageText,
    });
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

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: messageSender == currentUserId
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (messageSender != currentUserId)
                            const SizedBox(width: 10),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: messageSender == currentUserId
                                    ? Colors.blue[100]
                                    : Color.fromARGB(255, 98, 241, 186),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(messageText),
                            ),
                          ),
                        ],
                      ),
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
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: primaryColor,
            ),
          ),
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
                    await updateLatestMessage(_messageController.text);
                    _messageController.clear();

                    // Update latest message only if it's from the other user
                    await _firestore
                        .collection('chats')
                        .doc(widget.chatId)
                        .update({
                      'latestMessage': {
                        'sender': currentUserId == widget.recipientId
                            ? currentUserId
                            : widget.recipientId,
                        'text': _messageController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      }
                    });
                  }
                },
                icon: Icon(
                  Icons.send,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
