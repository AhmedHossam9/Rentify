import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'package:vehiclerent/providers/theme_provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _idNumberController = TextEditingController();
  String? _regionValue;
  String? _genderValue;

  List<String> _regions = [
    'Masr El Gdeda',
    'Madinet Nasr',
    'Madinty',
    'El-Obour',
    'El Sheroq',
    'Gesr Al Suez',
  ];

  List<String> _genders = ['Male', 'Female'];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
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
                  TextFormField(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
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
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black),
                    onChanged: (value) {
                      if (value.length > 11) {
                        _phoneNumberController.text = value.substring(0, 11);
                        _phoneNumberController.selection =
                            TextSelection.fromPosition(
                          TextPosition(
                              offset: _phoneNumberController.text.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length != 11) {
                        return 'Phone number must be 11 digits';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _idNumberController,
                    decoration: InputDecoration(
                      labelText: 'ID Number',
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
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black),
                    onChanged: (value) {
                      if (value.length > 14) {
                        _idNumberController.text = value.substring(0, 14);
                        _idNumberController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: _idNumberController.text.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your ID number';
                      }
                      if (value.length != 14) {
                        return 'ID number must be 14 digits';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField(
                    value: _regionValue,
                    items: _regions.map((region) {
                      return DropdownMenuItem(
                        value: region,
                        child: Text(region),
                      );
                    }).toList(),
                    hint: Text('Select Region'),
                    onChanged: (value) {
                      setState(() {
                        _regionValue = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a region';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField(
                    value: _genderValue,
                    items: _genders.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    hint: Text('Select Gender'),
                    onChanged: (value) {
                      setState(() {
                        _genderValue = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a gender';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: themeProvider.isDarkMode
                          ? Colors.lightBlueAccent
                          : Colors.blueAccent,
                      onPrimary: themeProvider.isDarkMode
                          ? Colors.black
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    icon: Icon(Icons.app_registration,
                        color: themeProvider.isDarkMode
                            ? Colors.black
                            : Colors.white),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        authProvider
                            .signUp(
                          email: _emailController.text,
                          password: _passwordController.text,
                          username: _usernameController.text,
                          address: _addressController.text,
                          phoneNumber: _phoneNumberController.text,
                          idNumber: _idNumberController.text,
                          region: _regionValue!,
                          gender: _genderValue!,
                        )
                            .then((_) {
                          if (authProvider.errorMessage.isEmpty) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                            );
                          }
                        });
                      }
                    },
                    label: Text('Sign Up'),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.login,
                        color: themeProvider.isDarkMode
                            ? Colors.lightBlueAccent
                            : Colors.blueAccent),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    label: Text(
                      'Have an account? Sign in',
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
      ),
    );
  }
}
