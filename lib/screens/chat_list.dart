import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vehiclerent/widgets/custom_bottom_nav_bar.dart';
import 'package:vehiclerent/contact.dart';

class ChatList extends StatelessWidget {
  final int currentIndex;

  ChatList({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('User not authenticated. Please log in.'),
        ),
        bottomNavigationBar: CustomBottomNavBar(currentIndex: currentIndex),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 40.0), // Padding to avoid notch
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Chats',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('participants', arrayContains: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No chats found'));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> chatData =
                          doc.data() as Map<String, dynamic>;
                      String chatId = doc.id;

                      // Extract other user ID
                      String otherUserId = chatData['participants']
                          .firstWhere((id) => id != user.uid);

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(otherUserId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              title: Text('Loading...'),
                            );
                          }
                          if (userSnapshot.hasError) {
                            return ListTile(
                              title: Text('Error loading user data'),
                            );
                          }
                          if (!userSnapshot.hasData ||
                              !userSnapshot.data!.exists) {
                            return ListTile(
                              title: Text('User not found'),
                            );
                          }

                          final userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;
                          String otherUserName =
                              userData['username'] ?? 'No name';

                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('messages')
                                .where('chatId', isEqualTo: chatId)
                                .where('read', isEqualTo: false)
                                .where('senderId', isEqualTo: otherUserId)
                                .snapshots(),
                            builder: (context, messageSnapshot) {
                              bool hasUnreadMessages =
                                  messageSnapshot.hasData &&
                                      messageSnapshot.data!.docs.isNotEmpty;

                              return Card(
                                elevation: 3,
                                margin: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(10.0),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    child: Text(
                                      otherUserName[0].toUpperCase(),
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  title: Text(
                                    otherUserName,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  trailing: hasUnreadMessages
                                      ? Icon(Icons.circle,
                                          color: Colors.red, size: 10)
                                      : null,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Contact(
                                          chatId: chatId,
                                          otherUserId: otherUserId,
                                          otherUserName: otherUserName,
                                          otherUserPhoneNumber: '', // Not used
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: currentIndex),
    );
  }
}
