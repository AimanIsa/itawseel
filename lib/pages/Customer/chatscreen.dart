import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;

  final Map<String, dynamic> user; // Received user data from previous screen

  const ChatScreen({Key? key, required this.user, required this.currentUserId})
      : super(key: key);

  get otherUser => null;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  late CollectionReference _chatCollection;
  late Stream<QuerySnapshot> _chatStream;

  @override
  void initState() {
    super.initState();
    // In the ChatScreen's initState or build method:

    // Create a unique chat ID based on both user IDs (ordered alphabetically)
    final orderedUserIds = [
      widget.currentUserId,
      widget.otherUser?['id'] ??
          'defaultUserId', // Provide a default value if null
    ];
    final chatId = '${orderedUserIds[0]}_${orderedUserIds[1]}';
    _chatCollection = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    // Fetch chat messages on initialization
    _chatStream = _chatCollection.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user['username'] != null
            ? widget.user['username']
            : 'No username'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages =
                    snapshot.data!.docs.map((doc) => doc.data()).toList();
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    // Display each message (customize as needed)
                    return Text(
                        (message as Map<String, dynamic>)['text']?.toString() ??
                            "No message text");
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _sendMessage();
                },
                icon: Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = {
      'text': _textController.text,
      'sender': widget.currentUserId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _chatCollection.add(message);
    _textController.clear();
  }
}
