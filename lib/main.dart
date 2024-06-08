import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this package
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vehiclerent/providers/auth_provider.dart';
import 'package:vehiclerent/providers/theme_provider.dart';
import 'package:vehiclerent/services/firebase_options.dart';
import 'package:vehiclerent/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Sign out user before running the app
  final authProvider = AuthProvider();
  await authProvider.signOut();

  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Vehicle Rent',
            theme: themeProvider.isDarkMode
                ? ThemeProvider.darkTheme
                : ThemeProvider.lightTheme,
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}
