import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:vehiclerent/widgets/custom_bottom_nav_bar.dart';

class NotificationPage extends StatelessWidget {
  final int currentIndex;
  final String userId;

  NotificationPage({required this.currentIndex, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('user_id', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No notifications found'),
            );
          }

          var notifications = snapshot.data!.docs
              .map((doc) => NotificationModel.fromDocument(doc))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      var notification = notifications[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text(
                            notification.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification.message),
                              SizedBox(height: 5),
                              Text(
                                DateFormat('MMM d, yyyy, h:mm a')
                                    .format(notification.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: notification.read
                              ? null
                              : Icon(Icons.circle, color: Colors.red, size: 10),
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection('notifications')
                                .doc(notification.id)
                                .update({'read': true});
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    var readNotifications = await FirebaseFirestore.instance
                        .collection('notifications')
                        .where('user_id', isEqualTo: userId)
                        .where('read', isEqualTo: true)
                        .get();

                    for (var doc in readNotifications.docs) {
                      await FirebaseFirestore.instance
                          .collection('notifications')
                          .doc(doc.id)
                          .delete();
                    }
                  },
                  icon: Icon(Icons.delete),
                  label: Text('Delete Read Notifications'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: currentIndex),
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.read,
  });

  factory NotificationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Missing data for notification');
    }

    // Ensure 'title' and 'message' are strings
    final title = data['title'] is String ? data['title'] : 'No title';
    final message = data['message'] is String ? data['message'] : 'No message';

    return NotificationModel(
      id: doc.id,
      title: title,
      message: message,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] ?? false, // Ensure 'read' is handled as boolean
    );
  }
}

Future<void> createNotification(
    String userId, String title, String message) async {
  if (title.isEmpty || message.isEmpty) {
    throw ArgumentError('Title and message cannot be empty');
  }

  await FirebaseFirestore.instance.collection('notifications').add({
    'user_id': userId,
    'title': title,
    'message': message,
    'timestamp': Timestamp.now(),
    'read': false,
  });
}
