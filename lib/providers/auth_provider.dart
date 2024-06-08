import 'package:flutter/material.dart';
import 'package:vehiclerent/services/auth_service.dart';
import 'package:vehiclerent/models/user.dart';
import 'package:vehiclerent/services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;
  String _errorMessage = '';

  User? get user => _user;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _authService.user?.listen((firebaseUser) async {
      if (firebaseUser != null) {
        _user = await _firebaseService.getUserData(firebaseUser.id);
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      _errorMessage = '';
      final firebaseUser =
          await _authService.signInWithEmailAndPassword(email, password);
      if (firebaseUser != null) {
        _user = await _firebaseService.getUserData(firebaseUser.id);
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String address,
    required String phoneNumber,
    required String idNumber,
    required String region,
    required String gender,
  }) async {
    try {
      _errorMessage = '';
      final firebaseUser =
          await _authService.createUserWithEmailAndPassword(email, password);
      if (firebaseUser != null) {
        final newUser = User(
          id: firebaseUser.id,
          email: email,
          username: username,
          address: address,
          phoneNumber: phoneNumber,
          idNumber: idNumber,
          region: region,
          gender: gender,
        );
        await _firebaseService.addUserData(firebaseUser.id, newUser.toMap());
        _user = newUser;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
