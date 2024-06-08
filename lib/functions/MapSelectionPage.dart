import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapSelectionPage extends StatefulWidget {
  @override
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  LatLng? _selectedLocation;
  String _locationName = '';
  LatLng _initialPosition = LatLng(30.0444, 31.2357); // Default to Cairo
  bool _locationFetched = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Inform the user that location services are disabled.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Inform the user that permission was denied.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permissions are denied.'),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permissions are permanently denied.'),
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _selectedLocation = _initialPosition;
        _locationFetched = true;
      });
    } catch (e) {
      // Handle potential errors.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get current location: $e'),
        ),
      );
    }
  }

  void _confirmSelection() {
    if (_selectedLocation != null && _locationName.isNotEmpty) {
      Navigator.pop(context, {
        'coordinates':
            '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
        'name': _locationName,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedLocation == null
              ? 'Please select a location on the map'
              : 'Please enter a location name'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick-up Location'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: _initialPosition,
              zoom: 13.0,
              onTap: (tapPosition, location) {
                setState(() {
                  _selectedLocation = location;
                  _locationFetched = true;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      builder: (ctx) => Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_locationFetched)
            Positioned(
              bottom: 100,
              left: 10,
              right: 10,
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        'Selected Location: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Location Name',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _locationName = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmSelection,
        child: Icon(Icons.check),
        tooltip: 'Confirm Selection',
      ),
    );
  }
}
