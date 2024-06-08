import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'sign_up_screen.dart';
import 'welcome_screen.dart';
import 'package:vehiclerent/providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 200,
                ),
                SizedBox(height: 20),
                Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                if (authProvider.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      authProvider.errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.black87),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.black87),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: themeProvider.isDarkMode
                              ? Colors.lightBlueAccent
                              : Colors.blueAccent),
                    ),
                  ),
                  style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.black87),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.black87),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: themeProvider.isDarkMode
                              ? Colors.lightBlueAccent
                              : Colors.blueAccent),
                    ),
                  ),
                  obscureText: true,
                  style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black),
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
                  icon: Icon(Icons.login,
                      color: themeProvider.isDarkMode
                          ? Colors.black
                          : Colors.white),
                  onPressed: () {
                    authProvider
                        .signIn(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    )
                        .then((_) {
                      if (authProvider.errorMessage.isEmpty) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  WelcomeScreen(currentIndex: 0)),
                        );
                      }
                    });
                  },
                  label: Text('Login'),
                ),
                TextButton.icon(
                  icon: Icon(Icons.app_registration,
                      color: themeProvider.isDarkMode
                          ? Colors.lightBlueAccent
                          : Colors.blueAccent),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  label: Text(
                    'Create an account',
                    style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.lightBlueAccent
                            : Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
