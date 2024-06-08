import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'location_view_page.dart';
import 'contact.dart';
import 'package:latlong2/latlong.dart';
import 'package:vehiclerent/screens/user_profile.dart';
import 'package:intl/intl.dart';
import 'rate.dart';

class RentRequests extends StatefulWidget {
  @override
  _RentRequestsState createState() => _RentRequestsState();
}

class _RentRequestsState extends State<RentRequests> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('You need to be logged in to see this page.')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfile(currentIndex: 4),
                        ),
                      );
                    },
                  ),
                  Text(
                    'Rental Requests',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 48), // Placeholder to balance the back button
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('vehicles')
                    .where('user_id', isEqualTo: user!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No vehicles listed'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot vehicleDoc = snapshot.data!.docs[index];
                      Map<String, dynamic> vehicleData =
                          vehicleDoc.data() as Map<String, dynamic>;

                      String vehicleStatus =
                          vehicleData['status'] ?? 'UP FOR RENT';
                      String vehicleName =
                          vehicleData['name'] ?? 'Unnamed Vehicle';

                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('renting_requests')
                            .where('vehicleId', isEqualTo: vehicleDoc.id)
                            .get(),
                        builder: (context, requestSnapshot) {
                          if (requestSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              title: Text(vehicleName),
                              subtitle: Text('Loading rental requests...'),
                            );
                          }
                          if (requestSnapshot.hasError) {
                            return ListTile(
                              title: Text(vehicleName),
                              subtitle: Text('Error loading rental requests'),
                            );
                          }

                          List<Widget> rentalRequestTiles = [];
                          if (requestSnapshot.hasData &&
                              requestSnapshot.data!.docs.isNotEmpty) {
                            rentalRequestTiles =
                                requestSnapshot.data!.docs.map((requestDoc) {
                              Map<String, dynamic> requestData =
                                  requestDoc.data() as Map<String, dynamic>;
                              DateTime startDate =
                                  (requestData['startDate'] as Timestamp)
                                      .toDate();
                              DateTime endDate =
                                  (requestData['endDate'] as Timestamp)
                                      .toDate();
                              int numberOfDays =
                                  endDate.difference(startDate).inDays + 1;

                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(requestDoc['userId'])
                                    .get(),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }
                                  if (userSnapshot.hasError) {
                                    return Text('Error loading user data');
                                  }
                                  if (!userSnapshot.hasData ||
                                      !userSnapshot.data!.exists) {
                                    return Text('User data not found');
                                  }

                                  Map<String, dynamic> userData =
                                      userSnapshot.data!.data()
                                          as Map<String, dynamic>;
                                  String username =
                                      userData['username'] ?? 'Unknown';
                                  String phoneNumber =
                                      userData['phone_number'] ?? 'Unknown';

                                  return ListTile(
                                    title: Text(
                                        'Request ID: ${requestDoc.id}, Region: ${requestData['regionName'] ?? 'Unknown'}, Coordinates: ${requestData['regionCoordinates'] ?? 'Unknown'}, Phone: $phoneNumber'),
                                    subtitle: Text(
                                        'Number of Days: $numberOfDays, Reason: ${requestData['reason']}, Start Date: ${DateFormat('yMd').format(startDate)}, End Date: ${DateFormat('yMd').format(endDate)}'),
                                    trailing: Wrap(
                                      spacing: 10,
                                      children: [
                                        if (vehicleStatus == 'UP FOR RENT') ...[
                                          ElevatedButton(
                                            onPressed: () => _acceptRequest(
                                                vehicleDoc.id,
                                                requestDoc.id,
                                                requestData['userId'],
                                                numberOfDays),
                                            child: Text('ACCEPT'),
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => _denyRequest(
                                                vehicleDoc.id,
                                                requestDoc.id,
                                                requestData['userId']),
                                            child: Text('DENY'),
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                        ],
                                        ElevatedButton(
                                          onPressed: () => _viewLocation(
                                              context,
                                              requestData['regionName'],
                                              requestData['regionCoordinates']),
                                          child: Text('LOCATION'),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _contactUser(
                                              context,
                                              requestData['userId'],
                                              username,
                                              phoneNumber),
                                          child: Text('CONTACT'),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.orange,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }).toList();
                          }

                          return Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ExpansionTile(
                              title: Text(vehicleName),
                              subtitle: Text(
                                  '${rentalRequestTiles.length} rental requests'),
                              children: [
                                ...rentalRequestTiles,
                                ElevatedButton(
                                  onPressed: () =>
                                      _deleteVehicle(vehicleDoc.id),
                                  child: Text('DELETE VEHICLE'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                if (vehicleStatus == 'RENTED')
                                  ListTile(
                                    title: Text('Cancel Rent'),
                                    onTap: () => _cancelRent(vehicleDoc.id,
                                        requestSnapshot.data!.docs.first.id),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewLocation(
      BuildContext context, String regionName, String coordinates) {
    final latLng = coordinates.split(', ').map(double.parse).toList();
    final location = LatLng(latLng[0], latLng[1]);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationViewPage(
          locationName: regionName,
          coordinates: location,
        ),
      ),
    );
  }

  void _contactUser(BuildContext context, String userId, String username,
      String phoneNumber) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to be logged in to contact.')),
      );
      return;
    }

    String chatId = await _getOrCreateChatId(currentUser.uid, userId);

    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Contact(
            chatId: chatId,
            otherUserId: userId,
            otherUserName: userData['username'] ?? 'Unknown',
            otherUserPhoneNumber: userData['phone_number'] ?? 'Unknown',
          ),
        ),
      );
    }
  }

  Future<String> _getOrCreateChatId(
      String currentUserId, String otherUserId) async {
    String chatId;

    QuerySnapshot chatQuery = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in chatQuery.docs) {
      List participants = doc['participants'];
      if (participants.contains(otherUserId)) {
        chatId = doc.id;
        return chatId;
      }
    }

    DocumentReference newChatDoc =
        await FirebaseFirestore.instance.collection('chats').add({
      'participants': [currentUserId, otherUserId],
      'createdAt': FieldValue.serverTimestamp(),
    });

    chatId = newChatDoc.id;
    return chatId;
  }

  void _acceptRequest(
      String vehicleId, String requestId, String userId, int numberOfDays) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference vehicleRef =
          FirebaseFirestore.instance.collection('vehicles').doc(vehicleId);
      DocumentReference requestRef = FirebaseFirestore.instance
          .collection('renting_requests')
          .doc(requestId);

      // Update vehicle status
      transaction.update(vehicleRef, {'status': 'RENTED'});

      // Delete other rental requests for this vehicle
      QuerySnapshot allRequests = await FirebaseFirestore.instance
          .collection('renting_requests')
          .where('vehicleId', isEqualTo: vehicleId)
          .get();

      for (var doc in allRequests.docs) {
        if (doc.id != requestId) {
          transaction.delete(doc.reference);
        }
      }
    }).then((_) async {
      print('Status updated to RENTED and other requests deleted');
      // Schedule to update the vehicle status after the rental period
      Future.delayed(Duration(days: numberOfDays), () {
        FirebaseFirestore.instance
            .collection('vehicles')
            .doc(vehicleId)
            .update({'status': 'UP FOR RENT'}).then((_) {
          print('Status updated to UP FOR RENT');
          // Show the rating form
          showRatingForm(context, requestId);
        }).catchError((error) => print('Failed to update status: $error'));
      });
      await createNotification(userId, 'Rental Request Accepted',
          'Your rental request has been accepted.');
    }).catchError((error) => print('Failed to update status: $error'));
  }

  void _denyRequest(String vehicleId, String requestId, String userId) {
    FirebaseFirestore.instance
        .collection('renting_requests')
        .doc(requestId)
        .delete()
        .then((_) async {
      print('Rental request deleted');
      await createNotification(userId, 'Rental Request Denied',
          'Your rental request has been denied.');
      setState(() {});
    }).catchError((error) => print('Failed to delete rental request: $error'));
  }

  void _cancelRent(String vehicleId, String requestId) async {
    try {
      DocumentSnapshot requestSnapshot = await FirebaseFirestore.instance
          .collection('renting_requests')
          .doc(requestId)
          .get();

      String renterId = requestSnapshot['userId'];

      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference vehicleRef =
            FirebaseFirestore.instance.collection('vehicles').doc(vehicleId);
        DocumentReference requestRef = FirebaseFirestore.instance
            .collection('renting_requests')
            .doc(requestId);

        // Update vehicle status
        transaction.update(vehicleRef, {'status': 'UP FOR RENT'});

        // Delete the rental request
        transaction.delete(requestRef);
      }).then((_) async {
        print('Rent canceled and status updated');
        await createNotification(renterId, 'Rent Canceled',
            'The rent has been canceled by the owner.');
        // Notify the owner
        await createNotification(user!.uid, 'Rent Canceled',
            'You have canceled the rent for vehicle ID: $vehicleId');
        setState(() {});
        // Show the rating form
        showRatingForm(context, requestId);
      }).catchError((error) => print('Failed to update status: $error'));
    } catch (e) {
      print('Error fetching rental request: $e');
    }
  }

  void _deleteVehicle(String vehicleId) {
    FirebaseFirestore.instance
        .collection('vehicles')
        .doc(vehicleId)
        .delete()
        .then((_) {
      print('Vehicle deleted');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle deleted successfully')),
      );
    }).catchError((error) {
      print('Failed to delete vehicle: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete vehicle')),
      );
    });
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
