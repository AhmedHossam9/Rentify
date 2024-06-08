import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'rate_owner.dart'; // Add this line

class RentedVehicles extends StatefulWidget {
  @override
  _RentedVehiclesState createState() => _RentedVehiclesState();
}

class _RentedVehiclesState extends State<RentedVehicles> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Rented Vehicles')),
        body: Center(child: Text('You need to be logged in to see this page.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Rented Vehicles'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('renting_requests')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No vehicles rented'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot requestDoc = snapshot.data!.docs[index];
              Map<String, dynamic> requestData =
                  requestDoc.data() as Map<String, dynamic>;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('vehicles')
                    .doc(requestData['vehicleId'])
                    .get(),
                builder: (context, vehicleSnapshot) {
                  if (vehicleSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading vehicle...'),
                    );
                  }
                  if (vehicleSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error loading vehicle'),
                    );
                  }
                  if (!vehicleSnapshot.hasData ||
                      !vehicleSnapshot.data!.exists) {
                    return ListTile(
                      title: Text('Vehicle data not found'),
                    );
                  }

                  Map<String, dynamic> vehicleData =
                      vehicleSnapshot.data!.data() as Map<String, dynamic>;

                  String vehicleName = vehicleData['name'] ?? 'Unnamed Vehicle';
                  String vehicleStatus = vehicleData['status'] ?? 'Unknown';

                  return ListTile(
                    title: Text(vehicleName),
                    subtitle: Text('Status: $vehicleStatus'),
                    trailing: vehicleStatus == 'RENTED'
                        ? ElevatedButton(
                            onPressed: () => _cancelRent(
                                requestData['vehicleId'],
                                requestDoc.id,
                                vehicleData['user_id']),
                            child: Text('CANCEL RENT'),
                          )
                        : null,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _cancelRent(String vehicleId, String requestId, String ownerId) {
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
      await createNotification(ownerId, 'Rent Canceled',
          'The rent for your vehicle has been canceled by the renter.');
      setState(() {});
      // Show the rating form for the vehicle owner
      showOwnerRatingForm(
          context, ownerId); // Correctly reference the method here
    }).catchError((error) => print('Failed to update status: $error'));
  }

  Future<void> createNotification(
      String userId, String title, String message) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'user_id': userId,
      'title': title,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
