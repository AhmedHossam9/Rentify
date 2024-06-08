import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vehiclerent/widgets/custom_bottom_nav_bar.dart'; // Import the custom bottom navigation bar
import 'package:vehiclerent/rent_related/RentVehicle.dart';
import 'package:vehiclerent/functions/contact.dart';

class FavoriteList extends StatefulWidget {
  final int currentIndex;

  FavoriteList({required this.currentIndex});

  @override
  _FavoriteListState createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  late ScaffoldMessengerState scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 40.0), // Padding to avoid notch
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Favorite Vehicles',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!['favorite_vehicles'] == null) {
                    return Center(child: Text('No favorite vehicles'));
                  }

                  List<String> favoriteVehicleIds =
                      List<String>.from(snapshot.data!['favorite_vehicles']);

                  if (favoriteVehicleIds.isEmpty) {
                    return Center(child: Text('No favorite vehicles'));
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('vehicles')
                        .where(FieldPath.documentId,
                            whereIn: favoriteVehicleIds)
                        .snapshots(),
                    builder: (context, vehicleSnapshot) {
                      if (vehicleSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (vehicleSnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${vehicleSnapshot.error}'));
                      }
                      if (!vehicleSnapshot.hasData ||
                          vehicleSnapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No favorite vehicles'));
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemCount: vehicleSnapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var vehicle = vehicleSnapshot.data!.docs[index];
                          var vehicleData =
                              vehicle.data() as Map<String, dynamic>;

                          // Check if the vehicle is rented
                          bool isRented = vehicleData['status'] == 'RENTED';

                          return Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      if (vehicleData['image_url'] != null)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          child: Image.network(
                                            vehicleData['image_url'],
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      else
                                        Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            color: Colors.grey.shade300,
                                          ),
                                          child: Icon(
                                            Icons.directions_car,
                                            size: 100,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      if (isRented)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'UNAVAILABLE',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.remove_circle,
                                            color: Colors.redAccent,
                                            size: 30,
                                          ),
                                          onPressed: () async {
                                            String vehicleId = vehicle.id;
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user?.uid)
                                                .update({
                                              'favorite_vehicles':
                                                  FieldValue.arrayRemove(
                                                      [vehicleId]),
                                            });

                                            scaffoldMessenger.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Vehicle removed from favorites'),
                                                action: SnackBarAction(
                                                  label: 'UNDO',
                                                  onPressed: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(user?.uid)
                                                        .update({
                                                      'favorite_vehicles':
                                                          FieldValue.arrayUnion(
                                                              [vehicleId]),
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    vehicleData['name'] ?? 'No Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Year: ${vehicleData['model_year'] ?? 'N/A'}',
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  ),
                                  Text(
                                    'Category: ${vehicleData['category'] ?? 'N/A'}',
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  ),
                                  Text(
                                    'Price: \$${vehicleData['price_per_day'] ?? 'N/A'} / day',
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (!isRented)
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RentVehicle(
                                                  vehicleId: vehicle.id,
                                                  pricePerDay: vehicleData[
                                                      'price_per_day'],
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.blueAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          child: Text('Rent now'),
                                        ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          var otherUserId =
                                              vehicleData['user_id'];
                                          var chatId;

                                          // Check for existing chat
                                          var chatQuery =
                                              await FirebaseFirestore.instance
                                                  .collection('chats')
                                                  .where('participants',
                                                      arrayContainsAny: [
                                                        user!.uid,
                                                        otherUserId
                                                      ])
                                                  .limit(1)
                                                  .get();

                                          if (chatQuery.docs.isNotEmpty) {
                                            chatId = chatQuery.docs.first.id;
                                          } else {
                                            // Create new chat
                                            var newChatDoc =
                                                await FirebaseFirestore.instance
                                                    .collection('chats')
                                                    .add({
                                              'participants': [
                                                user.uid,
                                                otherUserId
                                              ],
                                              'lastMessage': '',
                                              'lastMessageTimestamp':
                                                  FieldValue.serverTimestamp(),
                                            });
                                            chatId = newChatDoc.id;
                                          }

                                          // Fetch other user details
                                          var userDoc = await FirebaseFirestore
                                              .instance
                                              .collection('users')
                                              .doc(otherUserId)
                                              .get();

                                          if (userDoc.exists) {
                                            var userData = userDoc.data()
                                                as Map<String, dynamic>;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Contact(
                                                  chatId: chatId,
                                                  otherUserId: otherUserId,
                                                  otherUserName:
                                                      userData['username'],
                                                  otherUserPhoneNumber:
                                                      userData['phone_number'],
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.greenAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: Text('Contact'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
      bottomNavigationBar:
          CustomBottomNavBar(currentIndex: widget.currentIndex),
    );
  }
}
