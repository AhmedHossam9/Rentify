import 'package:flutter/material.dart';

class VehicleCard extends StatelessWidget {
  final String title;
  final String manufacturer;
  final String imageUrl;
  final String price;
  final bool isDarkMode;
  final bool isFavorited;
  final bool isRented;
  final VoidCallback onRent;
  final VoidCallback onContact;
  final VoidCallback onToggleFavorite;

  VehicleCard({
    required this.title,
    required this.manufacturer,
    required this.imageUrl,
    required this.price,
    required this.isDarkMode,
    required this.isFavorited,
    required this.isRented,
    required this.onRent,
    required this.onContact,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.grey.shade300,
                    ),
                    child: Icon(
                      Icons.directions_car,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                if (isRented)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Center(
                        child: Text(
                          'UNAVAILABLE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.red : Colors.red,
                    ),
                    onPressed: onToggleFavorite,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 5),
            Text(
              'Manufacturer: $manufacturer',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text(
              'Price: \$$price / day',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isRented)
                  ElevatedButton(
                    onPressed: onRent,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text('Rent now'),
                  ),
                ElevatedButton(
                  onPressed: onContact,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('Contact'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
