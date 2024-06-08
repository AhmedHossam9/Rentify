import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteProfile extends StatefulWidget {
  @override
  _DeleteProfileState createState() => _DeleteProfileState();
}

class _DeleteProfileState extends State<DeleteProfile> {
  final _passwordController = TextEditingController();
  bool _isDeleting = false;

  void _deleteUserAccount() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your password')),
      );
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _passwordController.text,
      );

      try {
        await user.reauthenticateWithCredential(credential);

        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        // Delete user account
        await user.delete();

        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } catch (e) {
        setState(() {
          _isDeleting = false;
        });
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deleting your account will remove all your data from our system. This action is irreversible.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Enter your password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isDeleting
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _deleteUserAccount,
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    child: Text('Delete Account'),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
