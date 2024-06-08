import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vehiclerent/providers/theme_provider.dart';
import 'package:vehiclerent/widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final int currentIndex;

  WelcomeScreen({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: _fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('No user data found'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;

            if (userData == null) {
              return Center(child: Text('No user data found'));
            }

            final profilePicture =
                userData['profile_picture'] ?? 'assets/images/profile_pic.jpeg';
            final subscribedCategories =
                List<String>.from(userData['subscribed_categories'] ?? []);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                // Top Greeting Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${userData['username']} 👋',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.logout),
                          color: isDarkMode ? Colors.white : Colors.black,
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                            );
                          },
                        ),
                        CircleAvatar(
                          backgroundImage: profilePicture.startsWith('assets')
                              ? AssetImage(profilePicture)
                              : NetworkImage(profilePicture) as ImageProvider,
                          radius: 24,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Random picks you may like!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Horizontal List of Vehicles
                Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                    future: _fetchVehicles(subscribedCategories),
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

                      final randomVehicles = snapshot.data!.docs..shuffle();
                      final selectedVehicles = randomVehicles.take(3).toList();

                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: selectedVehicles.map((doc) {
                          final vehicleData =
                              doc.data() as Map<String, dynamic>;
                          return placeCard(
                            doc.id,
                            vehicleData['name'] ?? 'No Name',
                            vehicleData['manufacturer'] ?? 'No Manufacturer',
                            vehicleData['image_url'] ?? '',
                            vehicleData['price_per_day']?.toString() ?? 'N/A',
                            isDarkMode,
                            vehicleData['favorite_by'] != null &&
                                vehicleData['favorite_by'].contains(
                                    FirebaseAuth.instance.currentUser?.uid ??
                                        ''),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: currentIndex),
    );
  }

  Future<DocumentSnapshot> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    } else {
      throw Exception('User not authenticated');
    }
  }

  Future<QuerySnapshot> _fetchVehicles(List<String> categories) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    if (categories.isEmpty) {
      return FirebaseFirestore.instance
          .collection('vehicles')
          .where('user_id', isNotEqualTo: user.uid)
          .limit(3)
          .get();
    }
    return FirebaseFirestore.instance
        .collection('vehicles')
        .where('category', whereIn: categories)
        .where('user_id', isNotEqualTo: user.uid)
        .limit(3)
        .get();
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

  Widget placeCard(String vehicleId, String title, String manufacturer,
      String imageUrl, String price, bool isDarkMode, bool isFavorited) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : AssetImage('assets/images/default_vehicle.jpeg')
                  as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // Vehicle Info
          Positioned(
            bottom: 10,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  manufacturer,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '\$$price / day',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Favorite Icon
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: Color.fromARGB(255, 170, 29, 29),
              ),
              onPressed: () {
                _toggleFavorite(vehicleId);
              },
            ),
          ),
        ],
      ),
    );
  }
}
