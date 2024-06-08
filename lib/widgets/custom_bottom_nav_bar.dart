import 'package:flutter/material.dart';
import 'package:vehiclerent/screens/vehicle_browse.dart';
import 'package:vehiclerent/screens/favorite_list.dart';
import 'package:vehiclerent/screens/user_profile.dart';
import 'package:vehiclerent/screens/welcome_screen.dart';
import 'package:vehiclerent/screens/chat_list.dart';
import 'package:vehiclerent/screens/notification_page.dart';
import 'package:vehiclerent/screens/subscribecategory.dart'; // Import the new screen
import 'package:firebase_auth/firebase_auth.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  CustomBottomNavBar({required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index != currentIndex) {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  WelcomeScreen(currentIndex: index),
              transitionDuration: Duration(milliseconds: 300),
              transitionsBuilder: (context, animation1, animation2, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(index > currentIndex ? 1 : -1, 0),
                    end: Offset.zero,
                  ).animate(animation1),
                  child: child,
                );
              },
            ),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  VehicleBrowse(currentIndex: index),
              transitionDuration: Duration(milliseconds: 300),
              transitionsBuilder: (context, animation1, animation2, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(index > currentIndex ? 1 : -1, 0),
                    end: Offset.zero,
                  ).animate(animation1),
                  child: child,
                );
              },
            ),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  SubscribeCategory(currentIndex: index), // Pass currentIndex
              transitionDuration: Duration(milliseconds: 300),
              transitionsBuilder: (context, animation1, animation2, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(index > currentIndex ? 1 : -1, 0),
                    end: Offset.zero,
                  ).animate(animation1),
                  child: child,
                );
              },
            ),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  FavoriteList(currentIndex: index),
              transitionDuration: Duration(milliseconds: 300),
              transitionsBuilder: (context, animation1, animation2, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(index > currentIndex ? 1 : -1, 0),
                    end: Offset.zero,
                  ).animate(animation1),
                  child: child,
                );
              },
            ),
          );
          break;
        case 4:
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  UserProfile(currentIndex: index),
              transitionDuration: Duration(milliseconds: 300),
              transitionsBuilder: (context, animation1, animation2, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(index > currentIndex ? 1 : -1, 0),
                    end: Offset.zero,
                  ).animate(animation1),
                  child: child,
                );
              },
            ),
          );
          break;
        case 5:
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  ChatList(currentIndex: index),
              transitionDuration: Duration(milliseconds: 300),
              transitionsBuilder: (context, animation1, animation2, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(index > currentIndex ? 1 : -1, 0),
                    end: Offset.zero,
                  ).animate(animation1),
                  child: child,
                );
              },
            ),
          );
          break;
        case 6:
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    NotificationPage(
                  currentIndex: index,
                  userId: user.uid,
                ),
                transitionDuration: Duration(milliseconds: 300),
                transitionsBuilder: (context, animation1, animation2, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(index > currentIndex ? 1 : -1, 0),
                      end: Offset.zero,
                    ).animate(animation1),
                    child: child,
                  );
                },
              ),
            );
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Browse',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Subscriptions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'User Hub',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) => _onItemTapped(context, index),
    );
  }
}
