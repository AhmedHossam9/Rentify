import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vehiclerent/screens/subscribecategory.dart';

class CategorySelectionPage extends StatefulWidget {
  final List<String> initialSelectedCategories;
  final int currentIndex;

  CategorySelectionPage({
    required this.initialSelectedCategories,
    required this.currentIndex,
  });

  @override
  _CategorySelectionPageState createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  List<String> availableCategories = [];
  List<String> selectedCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedCategories = List.from(widget.initialSelectedCategories);
    _fetchAvailableCategories();
  }

  Future<void> _fetchAvailableCategories() async {
    try {
      QuerySnapshot categoriesSnapshot = await FirebaseFirestore.instance
          .collection('vehicle_categories')
          .get();

      List<String> categories = categoriesSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['name'] as String?)
          .whereType<String>()
          .toList();

      setState(() {
        availableCategories = categories;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching available categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateSubscriptions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userDoc.set({'subscribed_categories': selectedCategories},
          SetOptions(merge: true));

      print('Updated subscriptions to: $selectedCategories');
    } catch (e) {
      print('Error updating subscriptions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Categories'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    SubscribeCategory(currentIndex: widget.currentIndex),
                transitionDuration: Duration(milliseconds: 300),
                transitionsBuilder: (context, animation1, animation2, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(-1, 0),
                      end: Offset.zero,
                    ).animate(animation1),
                    child: child,
                  );
                },
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await _updateSubscriptions();
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      SubscribeCategory(currentIndex: widget.currentIndex),
                  transitionDuration: Duration(milliseconds: 300),
                  transitionsBuilder: (context, animation1, animation2, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(animation1),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(10.0),
              children: availableCategories.map((category) {
                bool isSelected = selectedCategories.contains(category);
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                    title: Text(
                      category,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedCategories.remove(category);
                        } else {
                          selectedCategories.add(category);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
    );
  }
}
