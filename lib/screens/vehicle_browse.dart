import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vehiclerent/widgets/custom_bottom_nav_bar.dart';
import 'package:vehiclerent/rentrelated/RentVehicle.dart';
import 'package:vehiclerent/functions/Contact.dart';
import 'package:vehiclerent/widgets/custom_search_bar.dart';
import 'package:vehiclerent/widgets/vehicle_card.dart';

class VehicleBrowse extends StatefulWidget {
  final int currentIndex;

  VehicleBrowse({required this.currentIndex});

  @override
  _VehicleBrowseState createState() => _VehicleBrowseState();
}

class _VehicleBrowseState extends State<VehicleBrowse> {
  String? selectedCategory;
  List<String> categories = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();
  String searchQuery = '';
  double? minPrice;
  double? maxPrice;
  String? currentUserId;
  bool isDarkMode = false; // Assuming a simple flag for dark mode

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserId = user?.uid;
    });
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
          .collection('vehicle_categories')
          .get();
      setState(() {
        categories =
            categorySnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Error fetching categories: $e');
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

  Future<void> _contactOwner(BuildContext context, String otherUserId) async {
    var chatId;

    // Check for existing chat
    var chatQuery = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContainsAny: [
          FirebaseAuth.instance.currentUser!.uid,
          otherUserId
        ])
        .limit(1)
        .get();

    if (chatQuery.docs.isNotEmpty) {
      chatId = chatQuery.docs.first.id;
    } else {
      // Create new chat
      var newChatDoc =
          await FirebaseFirestore.instance.collection('chats').add({
        'participants': [FirebaseAuth.instance.currentUser!.uid, otherUserId],
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

  List<DocumentSnapshot> _filterVehicles(List<DocumentSnapshot> vehicles) {
    if (currentUserId == null) return vehicles;

    return vehicles.where((vehicle) {
      final vehicleData = vehicle.data() as Map<String, dynamic>;
      if (vehicleData['user_id'] == currentUserId) {
        return false;
      }

      final searchTerms = searchQuery.toLowerCase().split(' ');
      final modelYear = vehicleData['model_year']?.toString().toLowerCase();
      final manufacturer =
          vehicleData['manufacturer']?.toString().toLowerCase();
      final vehicleName = vehicleData['name']?.toString().toLowerCase();
      final price = vehicleData['price_per_day']?.toDouble();

      bool matchesSearchTerms = searchTerms.every((term) =>
          modelYear?.contains(term) == true ||
          manufacturer?.contains(term) == true ||
          vehicleName?.contains(term) == true);

      bool matchesPrice =
          (minPrice == null || (price != null && price >= minPrice!)) &&
              (maxPrice == null || (price != null && price <= maxPrice!));

      return matchesSearchTerms && matchesPrice;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomSearchBar(
              controller: searchController,
              onFilterPressed: showSearchDialog,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      hint: Text('Select Category'),
                      isExpanded: true,
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      clearSearchOptions();
                    },
                    style: ElevatedButton.styleFrom(
                      primary:
                          isDarkMode ? Colors.grey[800] : Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedCategory == null
                    ? FirebaseFirestore.instance
                        .collection('vehicles')
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('vehicles')
                        .where('category', isEqualTo: selectedCategory)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('No vehicles available for rent'));
                  }

                  final filteredVehicles = _filterVehicles(snapshot.data!.docs);

                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemCount: filteredVehicles.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot vehicleDoc = filteredVehicles[index];
                      Map<String, dynamic> vehicleData =
                          vehicleDoc.data() as Map<String, dynamic>;

                      bool isFavorited = (FirebaseAuth
                                  .instance.currentUser?.uid !=
                              null &&
                          (vehicleData['favorite_by'] as List<dynamic>?)
                                  ?.contains(
                                      FirebaseAuth.instance.currentUser!.uid) ==
                              true);

                      bool isRented = vehicleData['status'] == 'RENTED';

                      return VehicleCard(
                        title: vehicleData['name'] ?? 'No Name',
                        manufacturer: vehicleData['manufacturer'] ?? 'Unknown',
                        imageUrl: vehicleData['image_url'] ?? '',
                        price: vehicleData['price_per_day']?.toString() ?? '0',
                        isDarkMode: isDarkMode,
                        isFavorited: isFavorited,
                        isRented: isRented,
                        onRent: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RentVehicle(
                                vehicleId: vehicleDoc.id,
                                pricePerDay: vehicleData['price_per_day'],
                              ),
                            ),
                          );
                        },
                        onContact: () async {
                          var otherUserId = vehicleData['user_id'];
                          await _contactOwner(context, otherUserId);
                        },
                        onToggleFavorite: () {
                          _toggleFavorite(vehicleDoc.id);
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

  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Vehicles'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(hintText: 'Enter search terms'),
              ),
              TextField(
                controller: minPriceController,
                decoration: InputDecoration(hintText: 'Min Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: maxPriceController,
                decoration: InputDecoration(hintText: 'Max Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  searchQuery = searchController.text;
                  minPrice = minPriceController.text.isNotEmpty
                      ? double.tryParse(minPriceController.text)
                      : null;
                  maxPrice = maxPriceController.text.isNotEmpty
                      ? double.tryParse(maxPriceController.text)
                      : null;
                });
                Navigator.of(context).pop();
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void clearSearchOptions() {
    setState(() {
      searchQuery = '';
      minPrice = null;
      maxPrice = null;
      searchController.clear();
      minPriceController.clear();
      maxPriceController.clear();
      selectedCategory = null; // Clear selected category
    });
  }
}
