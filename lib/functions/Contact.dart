import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Contact extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserPhoneNumber;

  Contact({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPhoneNumber,
  });

  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _messageController = TextEditingController();
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');
  final CollectionReference _chatsCollection =
      FirebaseFirestore.instance.collection('chats');

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() async {
    if (user != null) {
      QuerySnapshot unreadMessagesSnapshot = await _messagesCollection
          .where('chatId', isEqualTo: widget.chatId)
          .where('read', isEqualTo: false)
          .where('senderId', isEqualTo: widget.otherUserId)
          .get();

      for (var doc in unreadMessagesSnapshot.docs) {
        await _messagesCollection.doc(doc.id).update({'read': true});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
        ),
        body: Center(
          child: Text('User not authenticated. Please log in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesCollection
                  .where('chatId', isEqualTo: widget.chatId)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> messageData =
                        doc.data() as Map<String, dynamic>;
                    bool isMine = messageData['senderId'] == user!.uid;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isMine ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: isMine
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                messageData['message'],
                                style: TextStyle(
                                  color: isMine ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                isMine ? 'You' : widget.otherUserName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isMine ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              if (messageData['read'] != null &&
                                  !messageData['read'] &&
                                  !isMine)
                                Icon(
                                  Icons.circle,
                                  color: Colors.red,
                                  size: 10,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) {
      return;
    }

    final currentUser = user; // Use a local variable for null safety
    if (currentUser == null) {
      // Handle the case where the user is null
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated. Please log in.')),
      );
      return;
    }

    final displayName = currentUser.displayName ?? 'Unknown';

    // Add the message to Firestore
    await _messagesCollection.add({
      'chatId': widget.chatId,
      'senderId': currentUser.uid,
      'message': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false, // Mark the message as unread initially
    });

    // Retrieve the participants from the chat document
    DocumentSnapshot chatSnapshot =
        await _chatsCollection.doc(widget.chatId).get();
    List<dynamic> participants = chatSnapshot['participants'];

    // Find the other participant's user ID
    String otherParticipantId = participants
        .firstWhere((id) => id != currentUser.uid, orElse: () => '');

    if (otherParticipantId.isNotEmpty) {
      // Create a notification for the recipient
      await FirebaseFirestore.instance.collection('notifications').add({
        'user_id': otherParticipantId,
        'title': 'You have unread messages!',
        'message': 'Check your chats!',
        'timestamp': Timestamp.now(),
        'read': false,
      });
    }

    _messageController.clear();
  }
}
