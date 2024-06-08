import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void showOwnerRatingForm(BuildContext context, String ownerId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      int rating = 0;
      TextEditingController commentController = TextEditingController();

      return AlertDialog(
        title: Text('Rate Vehicle Owner'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please rate the vehicle owner:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.yellow,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    labelText: 'Add a comment',
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            child: Text('Submit'),
            onPressed: () async {
              await _submitOwnerRating(ownerId, rating, commentController.text);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _submitOwnerRating(
    String ownerId, int rating, String comment) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    await FirebaseFirestore.instance.collection('owner_ratings').add({
      'ownerId': ownerId,
      'userId': user.uid,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.now(),
    });
  }
}
