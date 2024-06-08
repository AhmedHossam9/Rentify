import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void showRatingForm(BuildContext context, String rentalId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      int rating = 0;
      TextEditingController commentController = TextEditingController();

      return AlertDialog(
        title: Text('Rate Your Experience'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please rate your rental experience:'),
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
              await _submitRating(rentalId, rating, commentController.text);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _submitRating(String rentalId, int rating, String comment) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    await FirebaseFirestore.instance.collection('rent_ratings').add({
      'rentalId': rentalId,
      'userId': user.uid,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.now(),
    });
  }
}
