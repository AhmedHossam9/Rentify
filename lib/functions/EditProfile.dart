import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehiclerent/functions/DeleteProfile.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null) {
        _usernameController.text = userData['username'] ?? '';
        _addressController.text = userData['address'] ?? '';
        _phoneNumberController.text = userData['phone_number'] ?? '';
        _idNumberController.text = userData['id_number'] ?? '';
      }
    }
  }

  void _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Re-authenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        try {
          await user.reauthenticateWithCredential(credential);

          // Update password if provided
          if (_newPasswordController.text.isNotEmpty) {
            await user.updatePassword(_newPasswordController.text);
          }

          // Update Firestore user document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'username': _usernameController.text,
            'address': _addressController.text,
            'phone_number': _phoneNumberController.text,
            'id_number': _idNumberController.text,
          });

          Navigator.pop(context);
        } catch (e) {
          print('Error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _idNumberController,
                decoration: InputDecoration(labelText: 'ID Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ID number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(labelText: 'Current Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUserData,
                child: Text('Save'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DeleteProfile()),
                  );
                },
                style: ElevatedButton.styleFrom(primary: Colors.red),
                child: Text('Delete Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _idNumberController.dispose();
    _newPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }
}
