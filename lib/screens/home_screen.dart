import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';
import 'package:vehiclerent/providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> imgList = [
    'assets/images/background1.jpg',
    'assets/images/background2.jpeg',
    'assets/images/background3.jpeg',
  ];

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 2), // Faster loop
              autoPlayAnimationDuration:
                  Duration(milliseconds: 800), // Fading effect
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
            items: imgList
                .map((item) => Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(item,
                            fit: BoxFit.cover, width: double.infinity),
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                                sigmaX: 5, sigmaY: 5), // Blur effect
                            child: Container(
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ],
                    ))
                .toList(),
          ),
          Container(
            color: Colors.black.withOpacity(0.7), // Increased opacity
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png', // Ensure the path is correct
                  height: 300, // Make the logo larger
                ),
                SizedBox(height: 20),
                Text(
                  'Rentify',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Rent Easy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 22,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: themeProvider.isDarkMode
                        ? Colors.lightBlueAccent
                        : Colors.blueAccent,
                    onPrimary:
                        themeProvider.isDarkMode ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  icon: Icon(Icons.login,
                      color: themeProvider.isDarkMode
                          ? Colors.black
                          : Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  label: Text(
                    'Login',
                    style: TextStyle(
                        fontSize: 18,
                        color: themeProvider.isDarkMode
                            ? Colors.black
                            : Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: themeProvider.isDarkMode
                        ? Colors.lightBlueAccent
                        : Colors.blueAccent,
                    onPrimary:
                        themeProvider.isDarkMode ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  icon: Icon(Icons.app_registration,
                      color: themeProvider.isDarkMode
                          ? Colors.black
                          : Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  label: Text(
                    'Register',
                    style: TextStyle(
                        fontSize: 18,
                        color: themeProvider.isDarkMode
                            ? Colors.black
                            : Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: themeProvider.toggleTheme,
        child: Icon(
            themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
        backgroundColor: themeProvider.isDarkMode
            ? Colors.lightBlueAccent
            : Colors.blueAccent,
      ),
    );
  }
}
