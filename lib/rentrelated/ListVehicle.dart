import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:vehiclerent/screens/notification_page.dart';

class ListVehicle extends StatefulWidget {
  @override
  _ListVehicleState createState() => _ListVehicleState();
}

class _ListVehicleState extends State<ListVehicle> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelYearController = TextEditingController();
  final _insuranceExpiryController = TextEditingController();
  final _priceController = TextEditingController();
  String? _insuranceStatus;
  String? _selectedCategory;
  List<String> _categories = [];
  File? _imageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('vehicle_categories')
          .get();
      List<String> categories =
          snapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching categories')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef =
        FirebaseStorage.instance.ref().child('vehicle_images/$fileName');
    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _createNotificationForSubscribedUsers(String category) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('subscribed_categories', arrayContains: category)
          .get();

      for (var doc in snapshot.docs) {
        String userId = doc.id;
        await createNotification(
          userId,
          'New Vehicle Listed',
          'A new vehicle has been listed in your subscribed category: $category',
        );
      }
    } catch (e) {
      print('Error creating notifications: $e');
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String imageUrl = await _uploadImage(_imageFile!);

          DocumentReference newVehicleRef =
              FirebaseFirestore.instance.collection('vehicles').doc();

          await newVehicleRef.set({
            'id': newVehicleRef.id,
            'name': _nameController.text,
            'manufacturer': _manufacturerController.text,
            'model_year': _modelYearController.text,
            'insurance_status': _insuranceStatus,
            'insurance_expiry_date': _insuranceStatus == 'Insured'
                ? _insuranceExpiryController.text
                : null,
            'category': _selectedCategory,
            'price_per_day': double.parse(_priceController.text),
            'user_id': user.uid,
            'image_url': imageUrl,
          });

          // Create notifications for subscribed users
          await _createNotificationForSubscribedUsers(_selectedCategory!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vehicle listed successfully')),
          );

          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    } else if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List New Vehicle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the vehicle name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _manufacturerController,
                decoration: InputDecoration(labelText: 'Manufacturer'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the manufacturer';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _modelYearController,
                decoration: InputDecoration(labelText: 'Model Year'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the model year';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price Per Day'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price per day';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _insuranceStatus,
                decoration: InputDecoration(labelText: 'Insurance Status'),
                items: ['Insured', 'Not insured']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _insuranceStatus = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select the insurance status';
                  }
                  return null;
                },
              ),
              if (_insuranceStatus == 'Insured')
                TextFormField(
                  controller: _insuranceExpiryController,
                  decoration:
                      InputDecoration(labelText: 'Insurance Expiry Date'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the insurance expiry date';
                    }
                    return null;
                  },
                ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category'),
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  height: 150,
                ),
              SizedBox(height: 20),
              _isUploading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('List Vehicle'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manufacturerController.dispose();
    _modelYearController.dispose();
    _insuranceExpiryController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
