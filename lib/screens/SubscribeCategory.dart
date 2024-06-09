import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vehiclerent/widgets/custom_bottom_nav_bar.dart';
import 'package:vehiclerent/rentrelated/RentVehicle.dart';
import 'package:vehiclerent/functions/Contact.dart';
import 'package:vehiclerent/screens/CategorySelectionScreen.dart';
import 'package:vehiclerent/widgets/vehicle_card.dart';

class SubscribeCategory extends StatefulWidget {
  final int currentIndex;

  SubscribeCategory({required this.currentIndex});

  @override
  _SubscribeCategoryState createState() => _SubscribeCategoryState();
}

class _SubscribeCategoryState extends State<SubscribeCategory> {
  List<String> subscribedCategories = [];
  List<DocumentSnapshot> vehicles = [];
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _fetchSubscribedCategories();
  }

  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserId = user?.uid;
    });
  }

  Future<void> _fetchSubscribedCategories() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('subscribed_categories')) {
          setState(() {
            subscribedCategories =
                List<String>.from(userData['subscribed_categories'] ?? []);
          });
          await _fetchVehicles();
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching subscribed categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchVehicles() async {
    try {
      if (subscribedCategories.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      QuerySnapshot vehicleSnapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('category', whereIn: subscribedCategories)
          .get();

      setState(() {
        vehicles = vehicleSnapshot.docs
            .where((doc) =>
                (doc.data() as Map<String, dynamic>)['user_id'] !=
                currentUserId)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching vehicles: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _contactOwner(BuildContext context, String otherUserId) async {
    var user = FirebaseAuth.instance.currentUser;
    var chatId;

    // Check for existing chat
    var chatQuery = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContainsAny: [user!.uid, otherUserId])
        .limit(1)
        .get();

    if (chatQuery.docs.isNotEmpty) {
      chatId = chatQuery.docs.first.id;
    } else {
      // Create new chat
      var newChatDoc =
          await FirebaseFirestore.instance.collection('chats').add({
        'participants': [user.uid, otherUserId],
        'lastMessage': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });
      chatId = newChatDoc.id;
    }

    // Fetch other user details
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .get();

    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Contact(
            chatId: chatId,
            otherUserId: otherUserId,
            otherUserName: userData['username'] ?? 'Unknown',
            otherUserPhoneNumber: userData['phone_number'] ?? 'N/A',
          ),
        ),
      );
    }
  }

  Future<void> _toggleFavorite(String vehicleId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentReference vehicleDoc =
        FirebaseFirestore.instance.collection('vehicles').doc(vehicleId);

    DocumentSnapshot userSnapshot = await userDoc.get();
    DocumentSnapshot vehicleSnapshot = await vehicleDoc.get();

    List<dynamic> favoriteVehicles = [];
    if (userSnapshot.exists) {
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey('favorite_vehicles')) {
        favoriteVehicles = userData['favorite_vehicles'] ?? [];
      } else {
        await userDoc.set(
            {'favorite_vehicles': favoriteVehicles}, SetOptions(merge: true));
      }
    }

    List<dynamic> favoriteBy = [];
    if (vehicleSnapshot.exists) {
      Map<String, dynamic>? vehicleData =
          vehicleSnapshot.data() as Map<String, dynamic>?;
      if (vehicleData != null && vehicleData.containsKey('favorite_by')) {
        favoriteBy = vehicleData['favorite_by'] ?? [];
      } else {
        await vehicleDoc
            .set({'favorite_by': favoriteBy}, SetOptions(merge: true));
      }
    }

    if (favoriteVehicles.contains(vehicleId)) {
      favoriteVehicles.remove(vehicleId);
      favoriteBy.remove(user.uid);
    } else {
      favoriteVehicles.add(vehicleId);
      favoriteBy.add(user.uid);
    }

    await userDoc.update({'favorite_vehicles': favoriteVehicles});
    await vehicleDoc.update({'favorite_by': favoriteBy});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subscribed Categories',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategorySelectionPage(
                            initialSelectedCategories: subscribedCategories,
                            currentIndex: widget.currentIndex,
                          ),
                        ),
                      );
                      await _fetchSubscribedCategories(); // Refresh after returning
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : subscribedCategories.isEmpty
                      ? Center(child: Text('No subscriptions yet.'))
                      : vehicles.isEmpty
                          ? Center(
                              child: Text(
                                  'No vehicles available in your subscribed categories.'))
                          : ListView.builder(
                              padding: EdgeInsets.all(10.0),
                              itemCount: vehicles.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot vehicleDoc = vehicles[index];
                                Map<String, dynamic> vehicleData =
                                    vehicleDoc.data() as Map<String, dynamic>;
                                bool isFavorited =
                                    (FirebaseAuth.instance.currentUser?.uid !=
                                            null &&
                                        (vehicleData['favorite_by']
                                                    as List<dynamic>?)
                                                ?.contains(FirebaseAuth.instance
                                                    .currentUser!.uid) ==
                                            true);

                                bool isRented =
                                    vehicleData['status'] == 'RENTED';

                                return VehicleCard(
                                  title: vehicleData['name'] ?? 'No Name',
                                  manufacturer:
                                      vehicleData['manufacturer'] ?? 'N/A',
                                  imageUrl: vehicleData['image_url'] ?? '',
                                  price: vehicleData['price_per_day']
                                          ?.toString() ??
                                      'N/A',
                                  isDarkMode: false, // Change as necessary
                                  isFavorited: isFavorited,
                                  isRented: isRented,
                                  onRent: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RentVehicle(
                                          vehicleId: vehicleDoc.id,
                                          pricePerDay:
                                              vehicleData['price_per_day'],
                                        ),
                                      ),
                                    );
                                  },
                                  onContact: () {
                                    _contactOwner(
                                      context,
                                      vehicleData['user_id'],
                                    );
                                  },
                                  onToggleFavorite: () {
                                    _toggleFavorite(vehicleDoc.id);
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
