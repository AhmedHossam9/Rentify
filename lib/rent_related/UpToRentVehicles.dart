import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpToRentVehicles extends StatefulWidget {
  @override
  _UpToRentVehiclesState createState() => _UpToRentVehiclesState();
}

class _UpToRentVehiclesState extends State<UpToRentVehicles> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My Listed Vehicles'),
        ),
        body: Center(
          child: Text('You need to be logged in to view your vehicles.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Listed Vehicles'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .where('user_id', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No vehicles listed for rent.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot vehicleDoc = snapshot.data!.docs[index];
              Map<String, dynamic> vehicleData =
                  vehicleDoc.data() as Map<String, dynamic>;

              return ListTile(
                leading: vehicleData['image_url'] != null
                    ? Image.network(vehicleData['image_url'])
                    : Icon(Icons.directions_car),
                title: Text(vehicleData['name'] ?? 'No Name'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Year: ${vehicleData['model_year'] ?? 'N/A'}'),
                    Text('Category: ${vehicleData['category'] ?? 'N/A'}'),
                    Text(
                        'Price: \$${vehicleData['price_per_day'] ?? 'N/A'} / day'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('vehicles')
                        .doc(vehicleDoc.id)
                        .delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
