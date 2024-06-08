import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUserData(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(uid).set(userData);
  }

  Future<User?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return User.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
