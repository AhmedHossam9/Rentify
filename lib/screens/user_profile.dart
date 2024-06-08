import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vehiclerent/widgets/custom_bottom_nav_bar.dart';
import 'package:vehiclerent/EditProfile.dart';
import 'package:vehiclerent/RentalRequest.dart';
import 'package:vehiclerent/RentedVehicles.dart';
import 'package:vehiclerent/ListVehicle.dart'; // Import ListVehicle.dart
import 'package:vehiclerent/providers/theme_provider.dart';
import 'dart:io';

class UserProfile extends StatefulWidget {
  final int currentIndex;

  UserProfile({required this.currentIndex});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final ImagePicker _picker = ImagePicker();
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _changeProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && user != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child(user!.uid + '.jpg');
        await storageRef.putFile(File(pickedFile.path));
        final downloadUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'profile_picture': downloadUrl});
        setState(() {});
      } catch (e) {
        print('Error uploading profile picture: $e');
      }
    }
  }

  Future<double?> _fetchAverageRating(String userId) async {
    try {
      final ownerRatingsSnapshot = await FirebaseFirestore.instance
          .collection('owner_ratings')
          .where('ownerId', isEqualTo: userId)
          .get();

      final rentRatingsSnapshot = await FirebaseFirestore.instance
          .collection('rent_ratings')
          .where('userId', isEqualTo: userId)
          .get();

      List<double> ratings = [];

      for (var doc in ownerRatingsSnapshot.docs) {
        ratings.add(doc['rating'].toDouble());
      }

      for (var doc in rentRatingsSnapshot.docs) {
        ratings.add(doc['rating'].toDouble());
      }

      if (ratings.isEmpty) {
        return null;
      }

      double averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      return averageRating;
    } catch (e) {
      print('Error fetching ratings: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('User not authenticated. Please log in.'),
        ),
        bottomNavigationBar:
            CustomBottomNavBar(currentIndex: widget.currentIndex),
      );
    }

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
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
          final profilePicture =
              userData?['profile_picture'] ?? 'assets/images/profile_pic.jpeg';

          if (userData == null) {
            return Center(child: Text('No user data found'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40), // Top padding to avoid notch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'User Profile',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfile()),
                              );
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Dark Mode'),
                              Switch(
                                value: themeProvider.isDarkMode,
                                onChanged: (value) {
                                  themeProvider.toggleTheme();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  profilePicture.startsWith('assets')
                                      ? AssetImage(profilePicture)
                                      : NetworkImage(profilePicture)
                                          as ImageProvider,
                              radius: 50,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _changeProfilePicture,
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          userData['username'] ?? 'No Username',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FutureBuilder<double?>(
                          future: _fetchAverageRating(user!.uid),
                          builder: (context, ratingSnapshot) {
                            if (ratingSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (ratingSnapshot.hasError) {
                              return Text('Error: ${ratingSnapshot.error}');
                            }
                            if (!ratingSnapshot.hasData) {
                              return Text('Rating: Not available');
                            }
                            final averageRating = ratingSnapshot.data;
                            return Text(
                              'Rating: ${averageRating?.toStringAsFixed(1) ?? 'No rating'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        Text(
                          userData['address'] ?? 'No Address',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Phone: ${userData['phoneNumber'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'ID: ${userData['idNumber'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildActionButton(
                    context,
                    'View Rental Requests',
                    RentRequests(),
                  ),
                  _buildActionButton(
                    context,
                    'View Active Rentals',
                    RentedVehicles(),
                  ),
                  _buildActionButton(
                    context,
                    'List Vehicle',
                    ListVehicle(), // New button for listing a vehicle
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar:
          CustomBottomNavBar(currentIndex: widget.currentIndex),
    );
  }

  Widget _buildUserInfoRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not available',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
