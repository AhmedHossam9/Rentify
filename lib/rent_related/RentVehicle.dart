import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'MapSelectionPage.dart';
import 'package:intl/intl.dart';

class RentVehicle extends StatefulWidget {
  final String vehicleId;
  final double pricePerDay;

  RentVehicle({required this.vehicleId, required this.pricePerDay});

  @override
  _RentVehicleState createState() => _RentVehicleState();
}

class _RentVehicleState extends State<RentVehicle> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedReason = 'Personal';
  String? _selectedRegionName;
  String? _selectedRegionCoordinates;
  String _selectedPaymentMethod = 'Cash';
  double _totalPrice = 0.0;

  final List<String> _reasons = ['Personal', 'Business', 'Vacation', 'Other'];
  final List<String> _paymentMethods = ['Cash', 'Instapay'];

  @override
  void initState() {
    super.initState();
    _calculateTotalPrice();
  }

  void _calculateTotalPrice() {
    if (_startDate != null && _endDate != null) {
      setState(() {
        int days = _endDate!.difference(_startDate!).inDays + 1;
        _totalPrice = days * widget.pricePerDay;
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _endDate = null; // Reset end date when a new start date is selected
        _calculateTotalPrice();
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a start date first')),
      );
      return;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _calculateTotalPrice();
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedRegionName != null &&
        _selectedRegionCoordinates != null) {
      _formKey.currentState!.save();
      try {
        // Update the vehicle status
        await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(widget.vehicleId)
            .update({'status': 'UP FOR RENT'});

        // Add rental request
        DocumentReference rentalRequestRef = await FirebaseFirestore.instance
            .collection('renting_requests')
            .add({
          'vehicleId': widget.vehicleId,
          'startDate': _startDate,
          'endDate': _endDate,
          'reason': _selectedReason,
          'regionName': _selectedRegionName,
          'regionCoordinates': _selectedRegionCoordinates,
          'paymentMethod': _selectedPaymentMethod,
          'totalPrice': _totalPrice,
          'userId': FirebaseAuth.instance.currentUser?.uid,
          'rentalDate': Timestamp.now(),
        });

        // Get vehicle owner ID
        DocumentSnapshot vehicleSnapshot = await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(widget.vehicleId)
            .get();
        String vehicleOwnerId = vehicleSnapshot['user_id'];

        // Create notification for the vehicle owner
        await createNotification(vehicleOwnerId, 'New Rental Request',
            'You have a new rental request for vehicle ID: ${widget.vehicleId}.');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rental request submitted successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error submitting rental request: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting rental request')),
        );
      }
    } else {
      if (_selectedRegionName == null || _selectedRegionCoordinates == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a location on the map')),
        );
      }
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapSelectionPage()),
    );
    if (result != null) {
      setState(() {
        _selectedRegionName = result['name'];
        _selectedRegionCoordinates = result['coordinates'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rent Vehicle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  'Start Date: ${_startDate != null ? DateFormat('yMd').format(_startDate!) : 'Not selected'}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectStartDate(context),
              ),
              ListTile(
                title: Text(
                  'End Date: ${_endDate != null ? DateFormat('yMd').format(_endDate!) : 'Not selected'}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectEndDate(context),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Reason for Renting'),
                value: _selectedReason,
                onChanged: (newValue) {
                  setState(() {
                    _selectedReason = newValue!;
                  });
                },
                items: _reasons.map((reason) {
                  return DropdownMenuItem<String>(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
              ),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Pick-up Region',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.map),
                    onPressed: _selectLocation,
                  ),
                ),
                controller: TextEditingController(
                  text: _selectedRegionName != null
                      ? '$_selectedRegionName ($_selectedRegionCoordinates)'
                      : '',
                ),
                validator: (value) {
                  if (_selectedRegionName == null ||
                      _selectedRegionCoordinates == null) {
                    return 'Please select a location on the map';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Payment Method'),
                value: _selectedPaymentMethod,
                onChanged: (newValue) {
                  setState(() {
                    _selectedPaymentMethod = newValue!;
                  });
                },
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text(
                'Total Price: \$${_totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> createNotification(
    String userId, String title, String message) async {
  if (title.isEmpty || message.isEmpty) {
    throw ArgumentError('Title and message cannot be empty');
  }

  await FirebaseFirestore.instance.collection('notifications').add({
    'user_id': userId,
    'title': title,
    'message': message,
    'timestamp': Timestamp.now(),
    'read': false,
  });
}
